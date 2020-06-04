import logging
import gitlab
from time import sleep
import re

logger = logging.getLogger('daily_record')
handler = logging.StreamHandler()
formatter = logging.Formatter('[%(name)s|%(levelname)-4s]: %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)
logger.setLevel(logging.DEBUG)


class GITES:
    def __init__(self):
        self.gitlab_addr = 'http://gitlab.escapelife.com'
        self.gitlab_token = 'It is a secret'
        self.daily_work_list = []
        self.daily_work_project_id = 10
        self.daily_record_project_id = 10
        self.daily_record_issue_id = 3
        self.gl = self._get_gitlab()

    def _get_gitlab(self):
        return gitlab.Gitlab(self.gitlab_addr, private_token=self.gitlab_token)

    def _get_project(self, project_id=None):
        if project_id != None:
            return self.gl.projects.get(project_id)
        else:
            logger.error(f'The {project_id} is None, please check again!')

    def _get_work_list(self):
        logger.info('Generating a log task list, please waiting ...')
        awesome_work = self._get_project(project_id=self.daily_work_project_id)
        issues = awesome_work.issues.list(labels=['Done'])
        for issue in issues:
            issus_id = issue.get_id()
            self.daily_work_list.append(issue.notes.list(
                order_by='created_at', sort='desc')[0].body)
        logger.info('The list of log tasks is shown below:\n')
        [print(re.sub('\n', '', daily_work, 1), end='\n\n') for daily_work in self.daily_work_list]

    def _push_daily_record(self):
        logger.info('Start pushing work tasks to gitpd ...')
        wenpan_journal = self._get_project(self.daily_record_project_id)
        journal_issue = wenpan_journal.issues.get(self.daily_record_issue_id)
        journal_note = journal_issue.notes.create({'body': '\n'.join(self.daily_work_list)})
        journal_note.save()
        logger.info('Today is log task was successfully launched! ^_^')

    def main(self):
        self._get_work_list()
        logger.info('Do I need to submit?(y/n)')
        input_key = input()
        if input_key.lower() == 'y':
            self._push_daily_record()

        else:
            logger.info('Bye ~~~')


if __name__ == "__main__":
    gites = GITES()
    gites.main()
