---
title: "How to Build a Time Machine (with Git)"
author: "Paul Wang"
theme: "Antibes"
colortheme: "default"
fonttheme: "professionalfonts"
fontsize: 12pt
linkstyle: bold
aspectratio: 169
date: 2024 July
section-titles: true
toc: true
---
# Setting the Scene
## Setting the Scene

- Today's talk is **not** about specific commands / code.
- The goal is to show Git's elegant design, and demystify how it works.
- Reference will be included at the end on how to get specific things done, for those interested.

# A Typical Pickle
## A Typical Pickle

- Alice was working on a new feature for her project.
- She was 42% done when
	- Her boss, Bob, sent her a message on Teams.
	- There was an urgent bug in the code that needs fixing now.
- Alice wanted switch gear to patch the bug but
	- she doesn't want to give up her *WIP* feature. However, the feature code is not in a working state.
- What to do?

## Scenario #1: No Version Control

- Perhaps Alice copied the files before starting working on the new feature.
	- Save the feature works into a "feature" copy.
	- Find the newest clean copy (without the feature but one that contains the bug).
	- Make another copy, "bug_fix", of it.
	- Patch the bug.
	- Email everyone about the fix, and where to get the latest bug-free copy.
	- Go back to the "feature" copy.
	- Try to merge the WIP feature implementation onto the "bug_fix" copy.

## Scenario #1: No Version Control
- There are quite a few pitfalls with this approach:
	- One is out of luck if there wasn't a copy with the desired state.
	- This will be slow/space-consuming if you have a lot of files.
	- This is also dangerous as one might overwrite the wrong file.
	- It is hard to make sure that the copies were merge cleanly.
	- It is impossible to coordinate these works between two or more persons, or to take over from another person.
	- It is impossible to remember what happened after a few months.

# What is Version Control System?
## What is Version Control System?

- Version control is a system that records changes to a file or set of files over time so that one can recall specific versions later.
- Using a VCS also generally means that if you screw things up or lose files, you can easily recover.
- It allows code archaeology (when was the bug introduced? / how was it fixed? / how has this function evolved? / … ).
- More complex workflows are built upon it (collaboration, permission, code review, and releasing).

## What makes Git a Unique VCS?

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
## What is a Commit?
## Pickle Revisited
## Branching to the Rescue
## What is a Branch?
## Pointer (and more Pointer)
## Pickle Re-revisited
