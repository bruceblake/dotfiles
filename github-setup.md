# Setting up your GitHub Repository

1. Go to https://github.com/new to create a new repository
2. Name it `dotfiles`
3. Make it public (or private if you prefer)
4. Don't initialize it with any files (no README, .gitignore, or license)
5. Click "Create repository"

## Adding your remote repository

After creating the repository, run these commands:

```bash
# Navigate to your dotfiles directory
cd /home/proxyie/dotfiles

# Add the remote repository (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/dotfiles.git

# Push your code to GitHub
git push -u origin master
```

## Using GitHub CLI (alternative)

If you have GitHub CLI installed, you can create and push to the repository with:

```bash
# Navigate to your dotfiles directory
cd /home/proxyie/dotfiles

# Create and push to a new repository
gh repo create dotfiles --public --source=. --push
```