#! /bin/bash
if [ -f "~/.ssh/id_rsa_github2" ]
then
  echo "rsa key exists, moving on"
else
  ssh-keygen -f ~/.ssh/id_rsa_github2 -q -N ""
fi

if [ -z "${USERNAME}" ]
then
  echo "USERNAME not defined"
  exit
fi

if [ -z "${EMAIL}" ]
then
  echo "EMAIL not defined"
  exit
fi

git config --global user.name $USERNAME
git config --global user.email $EMAIL
export SSH_TMUX_KEY=`cat ~/.ssh/id_rsa_github2.pub`

echo "USERNAME = $USERNAME"
echo "EMAIL = $EMAIL"
echo "SSH_TMUX_KEY = $SSH_TMUX_KEY"

mkdir -p ~/ansible101
cd ~/ansible101

if [ "$(ls -A ~/static)" ]
then
  echo "Your ~/ansible101 directory is not empty, cowardly refusing to continue!"
  exit
else
  echo "~/ansible101 is empty, Excellent!"
fi

echo $TOKEN
if [ -z "${TOKEN}" ]
then
  echo "TOKEN not defined"
  exit
fi
curl -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $TOKEN" https://api.github.com/user/repos -d '{"name":"ansible101","description":"This is your first repo"}'
curl -X POST -H "Accept: application/vnd.github+json"   -H "Authorization: Bearer $TOKEN"   https://api.github.com/repos/$USERNAME/ansible101/keys   -d '{"title":"tmux_key","key":"'"$SSH_TMUX_KEY"'","read_only":false}'

cd ~/ansible101
git clone git@github.com:$USERNAME/ansible101.git ~/ansible101
touch $USERNAME.md
cat <<EOF >> ~/ansible101/.gitignore
echo "*.log" >> ~/ansible101/.gitignore
echo "*.key" >> ~/ansible101/.gitignore
echo "id_rsa*" >> ~/ansible101/.gitignore
EOF
git add *
git commit -m "my first commit"
git push origin HEAD
