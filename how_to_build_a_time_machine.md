---
title: "How to Build a Time Machine (with Git)"
author: "Paul Wang"
date: 2024 July
---
# Setting the Scene

- Today's talk is **not** about specific commands / code.

- I want to talk about some of Git's design decision, and from there talk about how we could take advantage of it.

- We will start with a scenario, then things will get visual and technical.

# A Typical Pickle

- Ross was working on a new feature for his project.
- He was 42% done when
	- His boss, Joey, sent him a message on Teams.
	- There was an urgent bug in the production code that needs fixing now.
- Ross needs to switch gear to patch the bug but
	- He doesn't want to give up his *WIP* feature. However, the feature code is not in a working state.
- What to do?

# No Version Control

- Perhaps Ross copied the files before starting working on the new feature.
	- Save the feature works into a "feature" copy.
	- Find the newest clean copy (without the feature but one that contains the bug).
	- Make another copy, "bug_fix", of it.
	- Patch the bug.
	- Email everyone about the fix, and where to get the latest bug-free copy.
	- Go back to the "feature" copy.
	- Try to manually merge the WIP feature implementation onto the "bug_fix" copy.
- Perhaps he didn't make a copy
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

- What Ross needs is something that helps him to go back in the history, diverge it, and merge it with his original timeline.
- A VCS is like a time machine for your code. It lets you travel back in time, and try different parallel timelines.
- It allows code archaeology (how was the bug introduced? / how was it fixed? / how has this function evolved? / … ).
- More complex workflows are built upon it (collaboration, permission, code review, and releasing).

# What makes Git a Unique VCS?

- Git is the most popular VCS. It has > 95% market share.
- It was first developed in 2005 for maintaining one of the largest open-source projects: the Linux Kernel.
  - Emailing all patches to one guy to merge -> Burnout -> Proprietary VCS Software -> Someone tried to reverse-engineer it -> No more free licenses -> "I will write my own VCS"

. . . 

    "Now, I’m dealing with the fall-out, and I’ll write my own kernel source tracking tool because I can’t use the best any more. That’s OK - I deal with my own problems, thank you very much." - Linus Torvalds

- Its design emphasizes:
    - **Efficiency**: Able to handle large projects, which has can has millions lines of code and thousands of collaborators.
    - **Strong support for non-linear development**: thousands of parallel branches.
    - Data Integrity: once added, hard to lose; everything is checksum-ed.
    - Distributed: every local copy is a fully copy; most actions can be done without Internet.

# Time Machine from Scratch

- Now let's try to understand Git.
- We will start from the basic - how Git see our files.
- Git sees every file in one of four states:
  1. untracked ("outside of the room")
  1. modified ("chaotic gathering in the room")
  2. staged ("people posing for a photo; adjusting frame")
  3. **committed ("the photo taken")** ← objective of the other steps

. . .

![](areas.png)

Eventually, we want to put things we care about into the committed state.

    Quiz: Why do we need a staging area? Why not just "save"?

# What is a Commit?

::: nonincremental
- Every time you commit, Git takes a picture of what all your files look like at that moment and stores a reference to that snapshot (so that it can be retrieved).

![](snapshots.png)
:::

- If the file didn't change, Git points the reference at the previous version.
- For files that changed, Git will prefer storing the whole file again not just the difference*.

. . .

![](deltas.png)  

Why not do this?

**Delta is space-friendly; full file is speed-friendly.** Git wants to make recreating the snapshot data fast.

# What is actually inside a commit?

Here is how a single commit looks like inside:

![](commit-and-tree.png)  

. . . 

And here is what happens if we made another one:

![](commits-and-parents.png)

    Quiz: How many parents can a commit have?

. . . 

Another way to look at it together:

![](data-model-3.png)

As we mentioned, duplicated data is not duplicatly stored, but referenced. Non-duplicated data is stored fully.

When we check out a commit, Git use the tree to find all data, decompressed them, and use that to populate our folder.

Notice how:

1. A commit has **snapshot**: a full map to find all the correct pieces of data!
2. A commit has **context**: author, timestamp, and commit message (who, when and why?)
3. A commit has **history**: always points to its parents; knows what comes before.


# What is a Branch?

So commit is contextual snapshot, and a chain of them forms a history.

. . .

How about multiple histories? Ross needs it.

. . .

This is where branches come in.

. . .

Branch is a movable pointer to a commit.

![](data-model-4.png)

When a branch is created, Git just writes down "test is at cac0ca...". It does not change the underlying files, copy files, compute, connect to Internet, whatever.

**Think of branching as making a bookmark, not copy-pasting.**

**Because of this, Git is optimized for fast and cheap branching**. People often create and delete multiple branches in a day, one for each topic they work on.

But how does Git know which branch you are on?

The answer is another pointer pointing to the branch pointer.

![](head-to-testing.png)

A special pointer, HEAD, marks the current branch.

Now if you make another commit 

![](advance-testing.png)

The pointer that HEAD points to, advanced, while the other pointer stays the same.

![](meme.jpg)

    Quiz: You checked out a commit, Git says you are now in "detached HEAD state". What happened?!

This is it. Many actions in Git are just moving these pointers around.

For example:

- checkout/switch: move HEAD to point to another commit or branch
- reset: point current branch to an earlier commit.
- create a commit: take another snapshot that use current commit as a parent. Move the current branch to it.
- merge: try to create a commit that combine two parents. Move the current branch to it.

# Pickle Revisited

Now let's go back to our earlier pickle example. Assuming Ross starts his work when there was a master branch, tracking prod.

![](basic-branching-1.png)

. . . 

He creates a new branch ("iss53") to track his feature works.

![](basic-branching-2.png)

And do some works (C3) on that branch.

![](basic-branching-3.png)

. . . 

Now, if there is bug now, he can easily checkout "master", create a "hotfix" branch and commit a fix (C4). His feature works are intact on "iss53".

![](basic-branching-4.png)

Then he can deploy the fix by merging "master" into "hotfix". Since Git can reach "hotfix" by fast-forwarding "master", it does that. "master" now is same as "hotfix".

![](basic-branching-5.png)

. . .

Now crisis averted Ross deletes the "hotfix" branch, and goes back to finish his feature (C5). After few days, it is ready to be integrated into master.

![](basic-branching-6.png)

Since the history has diverged, "master" cannot reach "iss53" by fast-forward. The new commit will have two parents.

If each's change relative to the ancestor (C2) is not overlapping (i.e. different files / lines), Git will merge them automatically. If it overlaps, then it is a conflict and Git will ask which side you want.

Most of time things merge cleanly automatically if the code is compartmentalized well.

![](basic-merging-1.png)

The branch being merged into, "master", advanced. Now both the fix and the new feature are in prod!

![](basic-merging-2.png)

Notice in this case how Ross can be a team of people all these will still work well!

# Local Branches are Disposable

Git branches are cheap (enabled by pointer), and switching branch fast (enabled by snapshot). Why is that important?

. . . 

Because one can experiment and context switch with very little consequences in a rapid manner. Like this:

![](topic-branches-1.png)

In other VCS (or not VCS) where branching by copying files and switching by adding up deltas, it could take minutes each time you diverge or switch to another branch.

. . . 

Let's say you conclude the v2 works better than v1, and the dumbidea is actually brilliant. You can delete the unused branch (throwing away C5 and C6).

![](topic-branches-2.png)

It’s important to remember these actions are **completely local**. When you’re branching and merging, everything is done offline — there is no communication with the server unless you requested it to be pushed.

**Have a lot of local branches. Dump the bad ones, polish the good ones, and share them when ready.**

# Take Away

- VCS is better than no VCS.
- A commit in Git is a contextual snapshot; chain of them forms the history.
- Git is designed around fast switching, and light-weight, disposable branching. 
- Don't be afraid to create many local branches and use them to your advantage.
- Further Reading
  - [The history of Git](https://blog.brachiosoft.com/en/posts/git/)
  - [Pro Git Book](https://git-scm.com/book/en/v2)
