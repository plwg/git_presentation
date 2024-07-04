---
title: "How to Build a Time Machine (with Git)"
author: "Paul Wang"
date: 2024 July
---
# Setting the Scene

- Today's talk is **not** about specific commands / code.

- The goal is to talk about Git's design decision, and from there understand how we should use it 

- Things might be a bit dry at the beginning but more visual later.

# A Typical Pickle

- Alice was working on a new feature for her project.
- She was 42% done when
	- Her boss, Bob, sent her a message on Teams.
	- There was an urgent bug in the code that needs fixing now.
- Alice wanted switch gear to patch the bug but
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
- Perhaps she didn't
    - 🫡


# No Version Control
::: nonincremental
- There are quite a few pitfalls with this approach:
	1. One is out of luck if there wasn't a copy with the desired state.
	2. This will be time/space-consuming if you have a lot of files.
	3. This is also dangerous as one might overwrite the wrong file.
	4. It is hard to make sure that the copies were merge cleanly.
	5. It is impossible to coordinate these works between two or more persons, or to take over from another person.
	6. It is impossible to remember what happened after a few months.
:::

# What is Version Control System?

- Version control is a system that records changes to a file or set of files over time so that one can recall specific versions later.
- Using a VCS also generally means that if you screw things up or lose files, you can easily recover.
- It allows code archaeology (when was the bug introduced? / how was it fixed? / how has this function evolved? / … ).
- More complex workflows are built upon it (collaboration, permission, code review, and releasing).

# What makes Git a Unique VCS?

- Git is the most popular VCS. It is used by most code platforms (Github / Gitlab / Bitbucket) and open-source projects.
- It was developed in 2005 to move the Linux Kernel maintenance away from propriety VCS. 
- Its design emphasizes:
    - **Speed**
    - **Strong support for non-linear development (thousands of parallel branches)**
    - **Data Integrity** (once added, hard to lose)
    - **Simplicity**
    - Fully distributed
    - Ability to handle large project efficiently (speed and data size)

# Time Machine from Scratch

- Now let's look at how Git does its thing.
- We will start from the basic - how Git see our files.
- Git sees every file it tracks in one of three states:
  1. modified ("chaotic gathering")
  2. staged ("people pose for a photo")
  3. committed ("the photo taken")

. . .

![](areas.png)

- Why do we need a staging area? Why not just "save"?

# What is a Commit?

::: nonincremental
- Every time you commit, Git basically takes a picture of what all your files look like at that moment and stores a reference to that snapshot.
![](snapshots.png)
:::

- If the file didn't change, Git store a pointer to the previous version.
- For files that changed, Git will store the whole file again not just the difference*. Why?  
![](deltas.png)  
  - delta is storage friendly; snapshot is access friendly

# What is actually inside a commit?

These are all the information inside a commit:

![](commit.png)  

. . .

- tree: a key to a map of all the correct files
- parent: a unique key to the commit this one based on. How many?
- author: who originally wrote the code, and a timestamp
- committer: who applied the code, and a timestamp. Why?
- commit message

Git takes all these information and generates a new unique key (4ea0...)

# What is a Branch?

Because for each commit we know its parents, we can construct the history

![](commits-and-parents.png)

. . .

But having a history does not yet help our pickle. We need to be able to diverge the history, not overwrite it.

This is where branches come in.

. . .

Branch is a movable pointer to a commit.

![](two-branches.png)

When a branch is created, Git just writes down "testing: f30ab...". It does not copy files, computer, connect to Internet, whatever.

Hence it is very fast and cheap to create new branch. It is encouraged to create a branch for each topic you work on.

But how does Git know which branch you are on?

The answer is another pointer pointing to one of the pointers.

![](head-to-testing.png)

Now if you make another commit 

![](advance-testing.png)

The pointer that HEAD points to, advance, while the other pointer stays the same.

. . .

This is it. Most of the actions in Git are about manipulating these pointers and commits.


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
- merge: create a special kind of commit that combine two parents. Move the current branch to it.

# Pickle Revisited

Now let's go back to our earlier pickle example. Assuming Alice starts her work when there was a master branch, where it tracks the version in prod.

![](basic-branching-1.png)

. . . 

She creates a new branch to track her feature works.

![](basic-branching-2.png)

And makes a commit.

![](basic-branching-3.png)

. . . 

Now if there is bug now, she can easily checkout master (move HEAD there), create a hotfix branch (pointer) and commit a fix. Her feature works are intact.

![](basic-branching-4.png)

Then she can deploy the fix by merging master into hotfix. The merge is straight-forward because the common ancestor of "master" and "hotfix" is "master". Git just uses the newer "hotfix" as the parent.

![](basic-branching-5.png)

. . .

Now crisis averted Alice goes back to finish her feature. Now it is ready to be integrated into master.

![](basic-branching-6.png)

Since the history has diverge, the new commit will have two parents. If each's change relative to the ancestor is not overlapping, git will merge them automatically. If it overlaps, then it is a conflict and it have to be fixed manually.

![](basic-merging-1.png)

The branch being merge into, "master", advanced. Now both the fix and the new feature are in prod!

![](basic-merging-2.png)

# Branches are Disposable

I mentioned in Git branches are cheap, and switching branch fast. Why is that important?

Because you can experiment and context switch with very little consequences in a rapid manner. Like this:

![](topic-branches-1.png)

In other VCS (or not VCS) where branching by copying files or creating new copy, this could take minutes each time you diverge or switch to another branch.

. . . 

Let's say you conclude the v2 works better than v1, and the dumbidea is actually brilliant. You can clean up the unused branches and still end up with a clean history.

![](topic-branches-2.png)

# Take Away

- VCS is better than no VCS.
- Git is designed around extremely light-weight, fast, and disposable branching. Don't be afraid to create many branches and use them to your advantage.
- Refer to the [Pro Git Book](https://git-scm.com/book/en/v2) to learn more.
