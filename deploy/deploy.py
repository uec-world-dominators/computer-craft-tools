import glob
import discord
import os
import subprocess

client = discord.Client()

DISCORD_BOT_TOKEN = os.environ['DISCORD_APP_TOKEN']
REPOSITORY_PREFIX = os.environ['REPOSITORY_PREFIX']
SCRIPTS_DIR = os.environ['SCRIPTS_DIR']
COMPUTER_CRAFT_DIR = os.path.abspath(os.environ['COMPUTER_CRAFT_DIR'])
WORK_DIR = '/tmp/repo'


@client.event
async def on_ready():
    print(f'We have logged in as {client.user}')


@client.event
async def on_message(message: discord.Message):
    if message.author.name == 'GitHub':
        if len(message.embeds) > 0:
            embed: discord.Embed = message.embeds[0]
            if embed.url.startswith(REPOSITORY_PREFIX):
                git_checkout()
                deploy_files()


def init():
    if not os.path.isdir(WORK_DIR):
        subprocess.run(
            ['git', 'clone', '--depth=1', REPOSITORY_PREFIX, WORK_DIR],
            cwd=os.path.dirname(WORK_DIR),
        ).check_returncode()
        return True
    else:
        return False


def git_checkout():
    commands = [
        ['git', 'fetch', 'origin', 'master:master'],
        ['git', 'checkout', 'origin/master'],
        ['git', 'reset', '--hard origin/master'],
    ]

    init()

    for command in commands:
        subprocess.run(command,
                       cwd=WORK_DIR).check_returncode()


def deploy_files():
    targets = [e
               for e
               in glob.glob(os.path.join(COMPUTER_CRAFT_DIR, '*'))
               if os.path.isdir(e)]

    for target in targets:
        subprocess.run(['rsync', os.path.join(SCRIPTS_DIR, ''), target, '-ah'],
                       cwd=WORK_DIR).check_returncode()


if init():
    deploy_files()
client.run(DISCORD_BOT_TOKEN)
