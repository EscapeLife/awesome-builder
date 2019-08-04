# -*- coding: utf-8 -*-
"""
一个快速迭代的Docker部署的小程序

Usage:
    python3 docker_patch.py --help
    python3 docker_patch.py --code_path='/home/escape/github/awesome-builder' \
        --code_branch='master' --start_commit='aaaaaa' --end_commit='bbbbbbb' \
        --images_name='xxxxx/xxxxx:0.0.1'

Requirements:
    pip3 install sh click gitpython
"""

import os
import sys
import string
import shutil
import tarfile
import time
from random import choice
from pprint import pprint
from pathlib import Path
from collections import deque

import sh
import click
import gitdb
from git import Repo

GLOBAL_DIFF_FILES = []
DEFAULT_CODE_PATH = os.path.abspath(os.path.dirname(__file__))


class BaseClass:
    """定义基础基类"""
    def __init__(self, code_path, code_branch, start_commit, end_commit, images_name):
        self.code_path = code_path
        self.code_branch = code_branch
        self.start_commit = start_commit
        self.end_commit = end_commit
        self.images_name = images_name
        self.repo = Repo(self.code_path)


class Check(BaseClass):
    """参数环境状态检查"""
    def __init__(self, code_path, code_branch, start_commit, end_commit, images_name):
        super().__init__(code_path, code_branch, start_commit, end_commit, images_name)

    def _is_tool(self, commands):
        """检查必须命令是否存在"""
        from shutil import which
        for command in commands:
            if which(command) is None:
                print(f'[P_ERROR] The `{command}` command not found, please `apt install {command}` so and on.')
                sys.exit(1)
            else:
                print(f'[P_INFOS] The `{command}` command is ready install.')

    def _is_git_repo(self):
        """检查该路径是否是一个Git仓库"""
        git_repo = os.path.join(self.code_path, '.git')
        if not os.path.isdir(git_repo):
            print(f'[P_ERROR] The {git_repo} is not a git repo.')
            sys.exit(1)
        else:
            print(f'[P_INFOS] The `{git_repo}` is a git repo.')


    def _repo_is_dirty(self):
        """检查仓库是否未提交文件"""
        if len(self.repo.untracked_files) != 0:
            print(f'[P_ERROR] The repo is dirty about {self.repo.untracked_files}.')
            sys.exit(1)
        elif self.repo.is_dirty():
            print(f'[P_ERROR] The repo has some file not push to remote repository.')
            sys.exit(1)
        else:
            print(f'[P_INFOS] The `{self.repo.git_dir}` is a clean git repo.')

    def _commit_is_right(self):
        """检查分支和对应commit是否存在"""
        branchs = []
        [branchs.append(str(self.repo.refs[num])) for num in range(len(self.repo.refs))]
        try:
            if self.code_branch in branchs:
                if self.repo.commit(self.start_commit) and self.repo.commit(self.end_commit):
                    print(f"[P_INFOS] The `{self.code_branch}` is exist in the git repository.")
                    print(f"[P_INFOS] The `{self.start_commit}` and `{self.end_commit}` is exist in the git repository.")
            else:
                print(f"[P_ERROR] The `{self.code_branch}` is not found in the git repository.")
                sys.exit(1)
        except gitdb.exc.BadName:
            print(f"[P_ERROR] The `{self.start_commit}` or `{self.end_commit}` is not found in the git repository.")
            sys.exit(1)

    def _image_is_right(self):
        """检查镜像是否可以拉取到"""
        try:
            print(f"[P_INFOS] The `{self.images_name}` image is ready to download ...")
            sh.docker('pull', self.images_name)
            print(f"[P_INFOS] The `{self.images_name}` image is exist in docker repository.")
        except sh.ErrorReturnCode_1:
            print(f"[P_ERROR] The `{self.images_name}` image is not found in docker repository.")
            sys.exit(1)

    def run(self):
        """执行check内容"""
        try:
            self._is_tool(['git', 'docker'])
            self._is_git_repo()
            self._repo_is_dirty()
            self._commit_is_right()
            self._image_is_right()
        except SystemExit:
            print('[E_INFOS] === 打包需谨慎 使得万年船 ===')
            sys.exit(1)


class Diff(BaseClass):
    """获取分支commit差异文件列表"""
    def __init__(self, code_path, code_branch, start_commit, end_commit, images_name):
        super().__init__(code_path, code_branch, start_commit, end_commit, images_name)

    def _diff_file(self):
        """获取差异文件列表"""
        new_branch = self.repo.create_head(self.code_branch)
        if self.repo.active_branch != new_branch:
            new_branch.checkout()
            print(f"[P_WARRN] The `{self.repo.active_branch}` doesn't match `{self.code_branch}` so automatically change branch.")
        git = self.repo.git
        try:
            diff_files = git.diff('--name-only', self.start_commit, self.end_commit).split()
            GLOBAL_DIFF_FILES.append(diff_files)
            pprint(diff_files, indent=4)
        except git.exc.GitCommandError:
            print(f'[P_ERROR] The diff command execution failed.')
            sys.exit(2)

    def run(self):
        """执行diff内容"""
        try:
            self._diff_file()
        except SystemExit:
            print('[E_INFOS] === 打包需谨慎 使得万年船 ===')
            sys.exit(2)


class PATCH(BaseClass):
    """启动Docker获取编译后的SO文件"""
    def __init__(self, code_path, code_branch, start_commit, end_commit, images_name):
        super().__init__(code_path, code_branch, start_commit, end_commit, images_name)

    def _check_is_file(self, path):
        if Path(path).is_file():
            return True
        else:
            return False

    def _check_is_dir(self, path):
        if Path(path).is_dir():
            return True
        else:
            return False

    def _copy_file(self):
        """复制文件并打包
        特殊转换: yml -> ctc | py -> so/pyc
        """
        archive_dir = os.path.join(DEFAULT_CODE_PATH, 'dist')
        images_info = sh.docker("inspect", "--format", "'{{.GraphDriver.Data.UpperDir}}'", self.images_name)
        working_dir = sh.docker("inspect", "--format", "'{{.ContainerConfig.WorkingDir}}'", self.images_name)
        if images_info.exit_code == 0 and working_dir.exit_code == 0:
            images_path = images_info.stdout.decode('utf-8').strip().strip("'")
            working_path = working_dir.stdout.decode('utf-8').strip().strip("'")
            copy_file_path = ''.join([images_path, working_path])
            if not self._check_is_dir(archive_dir):
                os.makedirs(archive_dir)
            else:
                shutil.rmtree(archive_dir)

            diff_files = GLOBAL_DIFF_FILES.pop()
            for _file in diff_files:
                time.sleep(0.5)
                source_file_path = os.path.join(copy_file_path, _file)
                source_file_dirname = os.path.dirname(source_file_path)
                source_file_basename = os.path.basename(source_file_path)
                target_file_path = os.path.join(archive_dir, _file)
                target_file_dirname = os.path.dirname(target_file_path)
                target_file_basename = os.path.basename(target_file_path)

                if source_file_basename.endswith('.py'):
                    source_file_is_so = source_file_path.replace('.py', '.so')
                    source_file_is_pyc = source_file_path.replace('.py', '.pyc')
                    if self._check_is_file(source_file_is_so):
                        if not self._check_is_dir(target_file_dirname):
                            os.makedirs(target_file_dirname)
                        print(f'[P_INFOS] To {source_file_basename} file to {target_file_dirname} ...')
                        shutil.copy2(source_file_is_so, target_file_dirname)
                    elif self._check_is_file(source_file_is_pyc):
                        if not self._check_is_dir(target_file_dirname):
                            os.makedirs(target_file_dirname)
                        print(f'[P_INFOS] To {source_file_basename} file to {target_file_dirname} ...')
                        shutil.copy2(source_file_is_pyc, target_file_dirname)
                    else:
                        print(f'[P_INFOS] The file is not in image, pass ...')
                elif source_file_basename.endswith('.yml'):
                    source_file_is_yml = source_file_path.replace('.yml', '.ctc')
                    if self._check_is_file(source_file_is_yml):
                        if not self._check_is_dir(target_file_dirname):
                            os.makedirs(target_file_dirname)
                        print(f'[P_INFOS] To {source_file_basename} file to {target_file_dirname} ...')
                        shutil.copy2(source_file_is_yml, target_file_dirname)
                    else:
                        print(f'[P_INFOS] The file is not in image, pass ...')
                else:
                    if self._check_is_file(source_file_path):
                        if not self._check_is_dir(target_file_dirname):
                            os.makedirs(target_file_dirname)
                        print(f'[P_INFOS] To {source_file_basename} file to {target_file_dirname} ...')
                        shutil.copy2(source_file_path, target_file_dirname)
                    else:
                        print(f'[P_INFOS] The file is not in image, pass ...')
        else:
            print(f'[P_WARRN] The `{images_info}` or `{working_dir}` is not found.')
            sys.exit(3)

    def _get_tar_packages(self):
        local_time = time.strftime("%Y%m%d", time.localtime())
        archive_dir = os.path.join(DEFAULT_CODE_PATH, 'dist')
        archive_name = '_'.join([local_time, 'docker_patch.tar.gz'])
        if self._check_is_dir(archive_dir):
            with tarfile.open(archive_name, 'w:gz') as tar_packages:
                tar_packages.add(archive_dir, arcname=os.path.basename(archive_dir))
        print(f'[P_INFOS] The `{archive_name}` tar package has been generated successfully.')

    def run(self):
        """执行copy内容"""
        try:
            self._copy_file()
            self._get_tar_packages()
        except SystemExit:
            print('[E_INFOS] === 打包需谨慎 使得万年船 ===')
            sys.exit(3)


@click.command()
@click.option("--code_path", default=DEFAULT_CODE_PATH, type=click.Path(exists=True), help="Set code dir path.")
@click.option("--code_branch", default="master", help="Set code branch name.")
@click.option("--start_commit", help="Set code repo checkout start commit.")
@click.option("--end_commit", help="Set code repo checkout end commit.")
@click.option("--images_name", help="Set images download remote registry name.")
def main(code_path, code_branch, start_commit, end_commit, images_name):
    """一个快速迭代的Docker部署的小程序"""
    # 健康检查
    click.echo(click.style('>>> Start check info ...', fg='green'))
    check = Check(code_path, code_branch, start_commit, end_commit, images_name)
    check.run()
    # 差异文件
    click.echo(click.style('>>> Get between the commits diff file ...', fg='green'))
    diff = Diff(code_path, code_branch, start_commit, end_commit, images_name)
    diff.run()
    # 打补丁包
    click.echo(click.style('>>> Get docker images fix packs ...', fg='green'))
    patch = PATCH(code_path, code_branch, start_commit, end_commit, images_name)
    patch.run()


if __name__ == '__main__':
    main()

