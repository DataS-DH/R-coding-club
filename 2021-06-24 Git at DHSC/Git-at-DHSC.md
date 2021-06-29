Workshop held on 24 June 2021 on how Git works, and specifically on how Git works at DHSC.

Addendum on .gitignore files:

Sometimes, you have files in your RProject that should never be added to Github: for example, data files or other sensitive materials. To prevent accidentally adding these files to Git commits, you can use a .gitignore file. This lists all filetypes that Git will ignore, and so it will never give you the option of committing those files to Github.

There are a few options to create a .gitignore:

* When creating a new repository, you can select an option to add a .gitignore from template. There is an R template available.
* When cloning a repository in RStudio as a new project, a .gitignore is automatically added if none exists yet.
* If you're confident, you can type your own.

Inside the .gitignore, common features are:

* Ignoring any files of a particular type, for example `*.csv` will ignore all CSV files in the Project.
* Ignoring R structural files, for example `.RData` will ignore your workspace files.
* Ignoring any files in a particular folder, for example `responses` will ignore all files inside the responses folder within the Git project's root directory.

Git has extensive documentation on further features of .gitignore files: https://git-scm.com/docs/gitignore 

