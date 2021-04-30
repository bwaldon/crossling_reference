# Git instructions

### 1. Add all the files you want to commit first.

Do this by:

```
git add <file1>
git add <file2>
...
```

Or you can do

`git add <file1> <file2> <file3> ...`

#### What if you don't know which files you edited / want to commit?

Enter `git status` to check what files have changed.

Let's say that `file17` has changed. If you want to see all the actual changes made to `file17`, then enter `git diff file17`.

After you've `git add`ed all of your files:'



### 2. Commit those changes

One liner:

`git commit -m "Message Here bla bla bla"`.



### 3. Push those changes to the repo

Another one liner:

`git push origin master`.

The command-line will prompt you for you Github username and password.



### Done!