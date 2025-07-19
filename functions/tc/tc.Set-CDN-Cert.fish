function tc.Set-CDN-Cert -a profile certId cdnDomain -d "设置 CDN 域名证书"
  # 验证参数数量
  if test -z "$profile"; or test -z "$certId"; or test -z "$cdnDomain"
    echo "Usage: tc.Set-CDN-Cert <profile> <cert-id> <cdn-domain> [https-settings]"
    return 1
  end

  set -l profile $argv[1]
  set -l certId $argv[2]
  set -l cdnDomain $argv[3]

  # 检查 jq 是否安装用于 JSON 处理
  if not command -q jq
    echo "jq is required. Installing jq..."
    sudo apt update && sudo apt install -y jq
    if not command -q jq
      echo "jq installation failed. Please install manually: sudo apt install jq"
      return 1
    end
  end

  # 获取当前 CDN 配置
  echo "Retrieving current config for $cdnDomain"
  set -l config (tccli --profile $profile cdn DescribeDomainsConfig \
    --Domains.0.Name $cdnDomain \
    --output json 2>/dev/null)

  if not set -q config[1]
    echo "Failed to retrieve CDN configuration for $cdnDomain"
    return 1
  end

  # 提取当前 HTTPS 配置
  set -l https_config (echo $config | jq -r '.Domains[0].Https')

  if test "$https_config" = "null"
    # 创建新的 HTTPS 配置
    set https_config '{
      "Switch": "on",
      "Http2": "on",
      "OcspStapling": "on",
      "VerifyClient": "off",
      "CertInfo": {
        "CertificateId": "'$certId'",
        "Message": "Auto-updated by script"
      }
    }'
  else
    # 更新现有配置中的证书 ID
    set https_config (echo $https_config | jq --arg id "$certId" '.CertInfo.CertificateId = $id')
  end

  # 更新 CDN 配置
  echo "Updating HTTPS configuration for $cdnDomain"
  set -l update_result (tccli --profile $profile cdn UpdateDomainConfig \
    --Domain $cdnDomain \
    --Https "$https_config" \
    --output json 2>/dev/null)

  if set -q update_result[1]
    set -l request_id (echo $update_result | jq -r '.RequestId')
    if test -n "$request_id"
      echo "CDN certificate updated successfully. Request ID: $request_id"
      return 0
    end
  end

  echo "Failed to update CDN configuration. Check profile permissions and domain status."
  return 1
end