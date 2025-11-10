#!/usr/bin/env bash
set -euo pipefail

# create_deploy_ssh_user.sh
#
# 在服务器上：
# 1) 创建一个系统用户（如果不存在）
# 2) 为该用户生成一对 SSH key（默认 ed25519，无口令）
# 3) 把公钥写入该用户的 ~/.ssh/authorized_keys（允许该 key 登录）
# 4) 在脚本结束时打印私钥，便于你拷贝到 GitHub Actions 的 SSH_PRIVATE_KEY secret
#
# 注意：该脚本需要 root 权限来创建用户并设置文件所有权。请在服务器上以 root 或具有 sudo 权限的用户运行。

usage() {
  cat <<EOF
Usage: $0 [--username NAME] [--key-type TYPE] [--comment COMMENT]

Options:
  --username NAME    要创建的系统用户名（默认: github-deploy）
  --key-type TYPE    ssh key 类型，例如 ed25519 或 rsa (默认: ed25519)
  --comment COMMENT  生成 key 时的 comment（默认: "deploy@$(hostname)")
  -h|--help          显示此帮助并退出

示例 (以 root 运行):
  sudo bash $0 --username github --key-type ed25519 --comment "ci-deploy@myserver"

脚本会在运行结束后把私钥打印到 stdout，请立即将其复制并存入 GitHub 仓库的 Actions Secret（例如 SSH_PRIVATE_KEY）。
EOF
}

USERNAME="github-deploy"
KEY_TYPE="ed25519"
KEY_COMMENT="deploy@$(hostname)"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --username)
      USERNAME="$2"; shift 2;;
    --key-type)
      KEY_TYPE="$2"; shift 2;;
    --comment)
      KEY_COMMENT="$2"; shift 2;;
    -h|--help)
      usage; exit 0;;
    *)
      echo "Unknown arg: $1"; usage; exit 2;;
  esac
done

if [ "$(id -u)" -ne 0 ]; then
  echo "请以 root 用户或通过 sudo 运行此脚本" >&2
  exit 3
fi

echo "目标用户名: $USERNAME"
echo "key 类型: $KEY_TYPE"
echo "key comment: $KEY_COMMENT"

# create user if not exists
if id -u "$USERNAME" >/dev/null 2>&1; then
  echo "用户 '$USERNAME' 已存在，跳过创建步骤"
else
  echo "正在创建系统用户: $USERNAME"
  useradd --create-home --shell /bin/bash "$USERNAME"
  echo "用户创建完成"
fi

USER_HOME=$(eval echo "~$USERNAME")
SSH_DIR="$USER_HOME/.ssh"
AUTH_KEYS="$SSH_DIR/authorized_keys"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
chown "$USERNAME":"$USERNAME" "$SSH_DIR"

# 临时生成 key 的路径（仅在 root 下可写）
TMP_PRIV="/tmp/${USERNAME}_deploy_key"
TMP_PUB="${TMP_PRIV}.pub"

if [ -f "$TMP_PRIV" ] || [ -f "$TMP_PUB" ]; then
  rm -f "$TMP_PRIV" "$TMP_PUB"
fi

echo "生成 SSH key (无口令)..."
ssh-keygen -t "$KEY_TYPE" -f "$TMP_PRIV" -N "" -C "$KEY_COMMENT" >/dev/null

echo "把公钥追加到 $AUTH_KEYS"
cat "$TMP_PUB" >> "$AUTH_KEYS"
chmod 600 "$AUTH_KEYS"
chown "$USERNAME":"$USERNAME" "$AUTH_KEYS"

echo
echo "==== 私钥 (请复制整个内容并保存为私钥, e.g. id_ed25519) ===="
cat "$TMP_PRIV"
echo
echo "==== 公钥 (已安装到 $USERNAME 的 authorized_keys) ===="
cat "$TMP_PUB"
echo

echo "注意: 私钥已经在 /tmp 中生成，脚本会在打印后删除临时文件以降低泄漏风险。"

# 清理临时文件
rm -f "$TMP_PRIV" "$TMP_PUB"

echo "完成。现在请将上面打印的私钥内容复制到 GitHub 仓库的 Actions secret（例如 SSH_PRIVATE_KEY），然后 Actions 中使用该私钥进行 scp 上传。"

exit 0
