---
title: "How to Build a Time Machine (with Git)"
author: "Paul Wang"
date: 2024 July
---
# Setting the Scene

- Today's talk is **not** about specific commands / code.

- The goal is to talk about Git's design decision, and from there understand how we should use it.

- We will start with a scenario, then things will get visual and technical.

# A Typical Pickle

- Alice was working on a new feature for her project.
- She was 42% done when
	- Her boss, Bob, sent her a message on Teams.
	- There was an urgent bug in the production code that needs fixing now.
- Alice needs to switch gear to patch the bug but
	- she doesn't want to give up her *WIP* feature. However, the feature code is not in a working state.
- What to do?

# No Version Control

- Perhaps Alice copied the files before starting working on the new feature.
	- Save the feature works into a "feature" copy.
	- Find the newest clean copy (without the feature but one that contains the bug).
	- Make another copy, "bug_fix", of it.
	- Patch the bug.
	- Email everyone about the fix, and where to get the latest bug-free copy.
	- Go back to the "feature" copy.
	- Try to manually merge the WIP feature implementation onto the "bug_fix" copy.
- Perhaps she didn't make a copy
    - Pain


# No Version Control
::: nonincremental
- There are quite a few pitfalls with this approach:
1. **No backup**: If there wasn't a copy with the desired state, you're left with nothing but a bunch of useless files.
2. **Time-consuming**: This method is slow and laborious, especially when dealing with large file systems.
3. **Error-prone**: It's easy to overwrite the wrong file or lose important changes due to manual mistakes.
4. **Difficult merges**: Ensuring that copies merge cleanly is a tedious process prone to errors.
5. **Collaboration nightmare**: Coordinating works between multiple developers or taking over from someone else is impossible with this approach.
6. **Forgetfulness**: After a few months, it's nearly impossible to remember the intricacies of the process and what changes were made.
:::

# What is Version Control System?

- What Alice needs is something that helps her to go back in the history, diverge it, and merge it with her original timeline.
- A VCS is like a time machine for your code. It lets you travel back in time, and try different parallel timelines.
- It allows code archaeology (how was the bug introduced? / how was it fixed? / how has this function evolved? / … ).
- More complex workflows are built upon it (collaboration, permission, code review, and releasing).

# What makes Git a Unique VCS?

- Git is the most popular VCS. It has > 95% market share.
- It was developed in 2005 for maintaining one of the largest open-source project: the Linux Kernel 
  - Emailing all patches to one guy to merge -> Burnout -> Proprietary VCS Software -> Someone tried to reverse-engineer it -> No more free licenses -> "I will write my own VCS"

. . . 

> "Now, I’m dealing with the fall-out, and I’ll write my own kernel source tracking tool because I can’t use the best any more. That’s OK - I deal with my own problems, thank you very much." - Linus Torvalds

- Its design emphasizes:
    - **Efficiency**: Able to handle large projects, which has can has millions lines of code and thousands of collaborators.
    - **Strong support for non-linear development**: thousands of parallel branches.
    - Data Integrity: once added, hard to lose; everything is checksum-ed.
    - Distributed: every local copy is a fully copy; most actions can be done without Internet.

# Time Machine from Scratch

- Now let's look at how Git does its thing.
- We will start from the basic - how Git see our files.
- Git sees every file in one of three states:
  1. untracked ("outside of the room")
  1. modified ("chaotic gathering in the room")
  2. staged ("people posing for a photo")
  3. **committed ("the photo taken")** ← what makes up git history

. . .

![](areas.png)

- Why do we need a staging area? Why not just "save"?

# What is a Commit?

::: nonincremental
- Every time you commit, Git takes a picture of what all your files look like at that moment and stores a reference to that snapshot.
![](snapshots.png)
:::

- If the file didn't change, Git store a pointer to the previous version.
- For files that changed, Git will store the whole file again not just the difference*. Why?  
![](deltas.png)  
  - delta is storage friendly; snapshot is access friendly

# What is actually inside a commit?

Here is how a single commit looks like inside:

![](commit-and-tree.png)  

. . . 

And here is what happens if we made another one:

![](commits-and-parents.png)

How many parents can a commit have?

. . . 

Another way to look at it together:

![](data-model-3.png)

Notice how:

1. Same file is referenced repeatedly.
2. The tree can point to another tree, representing nested directory.

# What is a Branch?

So for each commit we know its parents, we can construct the history.

. . .

But Alice needs is more than a single history that she can go back and forth in. She needs to diverge, make changes, and merge the history.

. . .

This is where branches come in.

. . .

Branch is a movable pointer to a commit.

![](data-model-4.png)

When a branch is created, Git just writes down "test is at cac0ca...". It does not change the underlying files, copy files, compute, connect to Internet, whatever.

**Think of branching as making a bookmark, not copy-pasting.**

Hence it is very fast and cheap to create new branch. It is encouraged to create a branch for each topic you work on.

But how does Git know which branch you are on?

The answer is another pointer pointing to the branch pointer.

![](head-to-testing.png)

Now if you make another commit 

![](advance-testing.png)

The pointer that HEAD points to, advanced, while the other pointer stays the same.

. . .

This is it. Most of the actions in Git are just manipulating these pointers and commits.


![](meme.jpg)

- commit: snapshot
- branch: pointer to snapshot
- HEAD: pointer to branch
- current branch: the branch being pointed to by HEAD
- create a new branch: create a new pointer to existing snapshot
- delete a branch: delete an existing pointer
- checkout/switch: move HEAD to point to another commit or branch
- reset: point current branch to an earlier commit.
- create a commit: take another snapshot that use current commit as a parent. Move the current branch to it.
- merge: create a commit that combine two parents. Move the current branch to it.

# Pickle Revisited

Now let's go back to our earlier pickle example. Assuming Alice starts her work when there was a master branch, where it tracks the version in prod.

![](basic-branching-1.png)

. . . 

She creates a new branch ("iss53") to track her feature works.

![](basic-branching-2.png)

And do some works on that branch.

![](basic-branching-3.png)

. . . 

Now, if there is bug now, she can easily checkout "master", create a "hotfix" branch and commit a fix. Her feature works are intact on "iss53".

![](basic-branching-4.png)

Then she can deploy the fix by merging "master" into "hotfix". Since Git can reach "hotfix" by fast-forwarding "master", it does that. "master" now is same as "hotfix".

![](basic-branching-5.png)

. . .

Now crisis averted Alice deletes the "hotfix" branch, and goes back to finish her feature. After few days, it is ready to be integrated into master.

![](basic-branching-6.png)

Since the history has diverged, no fast-forwarding this time. The new commit will have two parents. 

If each's change relative to the ancestor is not overlapping (i.e. different files), git will merge them automatically. If it overlaps, then it is a conflict and Git will ask which side you want. 

Most of time things merge cleanly automatically if the code is compartmentalized well.

![](basic-merging-1.png)

The branch being merge into, "master", advanced. Now both the fix and the new feature are in prod!

![](basic-merging-2.png)

Notice in this case how Alice can be a team of people all these will work the same!

# Local Branches are Disposable

Git branches are cheap (enabled by pointer), and switching branch fast (enabled by snapshot). Why is that important?

. . . 

Because you can experiment and context switch with very little consequences in a rapid manner. Like this:

![](topic-branches-1.png)

In other VCS (or not VCS) where branching by copying files and switching by adding up deltas, it could take minutes each time you diverge or switch to another branch.

. . . 

Let's say you conclude the v2 works better than v1, and the dumbidea is actually brilliant. You can delete the unused branch (throwing away C5 and C6).

![](topic-branches-2.png)

It’s important to remember these actions are **completely local**. When you’re branching and merging, everything is done offline — there is no communication with the server unless you requested it to be pushed.

**Have a lot of local branches. Dump the bad ones, polish the good ones, and share them when ready.**

# Take Away

- VCS is better than no VCS.
- Git is designed around fast switching, and light-weight, disposable branching. 
- Don't be afraid to create many local branches and use them to your advantage.
- Further Reading
  - [The history of Git](https://blog.brachiosoft.com/en/posts/git/)
  - [Pro Git Book](https://git-scm.com/book/en/v2)
