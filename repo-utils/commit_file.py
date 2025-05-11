"""
This script is used to commit a file to a repository.

It will create a new file in the repository or overwrite an existing file with the contents of stdin.

"""

import sys
from github import Github
from github import Auth

def main():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo", '-r', type=str, required=True)
    parser.add_argument("--file", '-f', type=str, required=True)
    parser.add_argument("--message", '-m', type=str, required=True)
    parser.add_argument("--token", '-t', type=str, required=True)
    args = parser.parse_args()

    print(args.token)

    auth = Auth.Token(args.token)
    g = Github(auth=auth)

    repo = g.get_repo(args.repo)

    # check if the file exists already in repo
    try:
        current_file_contents = repo.get_contents(args.file)
        # overwrite the file
        repo.update_file(args.file, args.message, sys.stdin.read(), current_file_contents.sha)
    except:
        # create the file
        repo.create_file(args.file, args.message, sys.stdin.read())

if __name__ == "__main__":
    main()