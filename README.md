```
zHub
│
├── config/
│
├── design/
│
├── notebooks/
│
├── utils/
│
└── zHub/
	│
	└── procedures/
```

# Branches

## New branch

```
git checkout main
git checkout -b new_branch
git push -u origin new_branch
```

## Switch branch

```
git checkout branch_name
```

## Delete branch

```
git checkout main
git branch -D old_branch
git push origin --delete old_branch
git branch -r
```

## Merge and delete branch

```
git checkout main
git merge old_branch
git push origin main
git branch -d old_branch
git push origin --delete old_branch
```