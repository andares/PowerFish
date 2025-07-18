function tc.Upload-Cert -a profile domain -d
  # 验证参数数量
  if test -z "$profile"; or test -z "$domain"
    echo "Usage: tc.Upload-Cert <profile> <domain>"
    return 1
  end

  # 确保 tccli 已安装
  if not command -q tccli
    echo "tccli not found. Installing..."
    tc.Check-Tccli
    echo "tccli installed. Please configure profile using: tccli configure --profile $profile"
    return 1
  end

  # 检查 certbot 是否安装
  power.Check-Python
  power.Check-Certbot
  if not command -q certbot
    echo "certbot installation failed. Please check manually."
    return 1
  end

  # 验证证书目录是否存在
  set -l cert_dir "/etc/letsencrypt/live/$domain"
  if not test -d $cert_dir
    echo "Certificate directory not found: $cert_dir"
    echo "Make sure certbot has generated certificates for $domain"
    return 1
  end

  # 读取证书文件内容
  set -l cert_file "$cert_dir/fullchain.pem"
  set -l key_file "$cert_dir/privkey.pem"

  if not test -f $cert_file; or not test -f $key_file
    echo "Certificate files missing in $cert_dir"
    return 1
  end

  # 上传证书到腾讯云
  echo "Uploading certificate for $domain using profile $profile"
  set -l result (tccli --profile $profile ssl UploadCertificate \
    --certificate-type SVR \
    --certificate-public-key (cat $cert_file) \
    --certificate-private-key (cat $key_file) \
    --alias $domain \
    --repeatable \
    --output json 2>/dev/null)

  # 处理上传结果
  if set -q result[1]
    set -l cert_id (echo $result | jq -r '.CertificateId')

    if test -n "$cert_id" && test "$cert_id" != "null"
      echo "Certificate uploaded successfully. Certificate ID: $cert_id"
      echo $cert_id  # 输出证书 ID 供后续使用
      return 0
    else
      echo "Failed to extract certificate ID from response"
      echo "Raw response: $result"
    end
  else
    echo "Certificate upload failed. Check profile configuration and API permissions."
  end

  return 1
end