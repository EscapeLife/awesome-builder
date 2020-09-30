import json
import os
import shutil
from pprint import pprint

import click
import sh


class Cropper:
    """A mirrored patch pack generation tool"""

    def __init__(self, base_image, latest_image):
        self._base_image = base_image
        self._latest_image = latest_image

    def __run(self, cmd):
        return sh.bash('-c', str(' '.join(cmd))).stdout

    def __get_layers_from_image(self, path):
        output = self.__run(['tar', '-xf', path, 'manifest.json', '-O'])
        layers = json.loads(output)[0]['Layers']
        return [layer.split('/')[0] for layer in layers]

    def __get_intersection_layers(self):
        click.echo(click.style('=== 查看Docker镜像版本的差异 ===', fg='red'))
        base_image_manifest = set(self.__get_layers_from_image(self._base_image))
        latest_image_manifest = set(self.__get_layers_from_image(self._latest_image))
        image_intersection_list = list(base_image_manifest.intersection(latest_image_manifest))

        click.echo(click.style('>>> The base image manifest ...', fg='green'))
        pprint(base_image_manifest, indent=4)
        click.echo(click.style('>>> The latest image manifest ...', fg='green'))
        pprint(latest_image_manifest, indent=4)
        click.echo(click.style('>>> The base && latest manifest ...', fg='green'))
        pprint(image_intersection_list, indent=4)
        return image_intersection_list

    def export_lite_tar(self):
        dist_dir = self._latest_image.rstrip('.tar') + '_lite'
        dist_tar = self._latest_image.rstrip('.tar') + '_lite.tar'
        if os.path.isdir(dist_dir):
            shutil.rmtree(dist_dir)
        os.makedirs(dist_dir)
        exclude_layers = ['--exclude=' + layer for layer in self.__get_intersection_layers()]

        click.echo(click.style('=== 生成Docker版本差异补丁包 ===', fg='red'))
        click.echo(click.style('>>> To ceate docker image patch tar ...', fg='green'))
        self.__run(['tar', '-xpf', self._latest_image, '-C', dist_dir] + exclude_layers)
        self.__run(['tar', '-C', dist_dir, '-cpf', dist_tar, '.'])
        shutil.rmtree(dist_dir)
        click.echo(click.style(f'>>> The docker image patch is {dist_tar} ...', fg='green'))
        pprint(str(self.__run(['tar', 'tf', dist_tar])).split('\\n'), indent=4)


@click.command()
@click.option('-b', '--base-image', type=click.Path(exists=True), help='The previous version was a mirror image')
@click.option('-l', '--latest-image', type=click.Path(exists=True), help='The latest version of the mirror')
@click.pass_context
def create_patch(ctx, base_image, latest_image):
    """A mirrored patch pack generation tool"""
    ctx.obj = Cropper(base_image, latest_image)
    ctx.obj.export_lite_tar()


if __name__ == '__main__':
    create_patch()
