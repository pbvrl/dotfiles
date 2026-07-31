git config --global user.name "$(cat /run/secrets/git/USER_NAME)"
git config --global user.email "$(cat /run/secrets/git/USER_EMAIL)"
