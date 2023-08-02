# Giti
A Git utility that uses an interactive menu and gets user inputs to format the Git commits. It also handles the complete process of pulling, staging, committing, and pushing the code into the remote git server.

> Warning: Giti is still **EXPERIMENTAL**, and it’s highly recommended to use it with caution.

## Install
Still, there is no option to install Giti, but you can clone the repository and create an alias in your `.bashrc` or `.zshrc` file with the following format:
```
# Alias for the Giti script:
alias giti='bash ~/path/to/giti/giti.sh'
```

## Usage
### giti

If you have set the alias correctly, Giti’s help document would get shown when you run the `giti` command in your terminal environment. You can also show the help documents by running the `giti -h` and `giti --help` commands.

### giti push

If your work is done and you wanna upload your changes into your intended remote repository, all thing you need to do is to run the `giti push` command. Through the process, it stages your working tree files, commits them by getting your commit message as a required field, and description and reference link as additional optional fields, and then pushes them into the remote repository.

#### giti push -i

When you create a new branch, before being able to push anything, you need to set a remote branch as upstream; this would get done simply by adding an `-i` option to the push command.

#### giti push -r `Number`

Sometimes, you may wanna override your commit message to fix a typo or add a piece of missing information, or even wanna merge some of your last related commits to have a cleaner history. This option is what you need, and the `Number` is actually the number of commits you wanna replace with the new one.
> Warning: This command needs to perform a **force push**, and thus it could be risky to use it. Please run this command only if you exactly know what you’re doing.

#### giti push -t `tag-name`

This option attaches the user input as a tag to the latest commit and pushes it to the remote server. In the case you wanna assign a tag for a previous commit, you can add `--hash commit-hash` to the original command.

### giti setup

You can simply configure your git identity (name and email), locally or globally, by running the command.

#### giti setup --clear

Clear your git identity by adding `--clear` to the setup command.

## License
Giti is licensed under the GPLv3 license. See [LICENSE](https://github.com/mohsen-karami/giti/blob/master/LICENSE) for more information.
