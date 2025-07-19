function power.Check-Certbot
  # Check if certbot is installed
  if not command -q certbot
    echo "Installing certbot..."
    if not sudo apt install -y certbot
      echo "Failed to install certbot!" >&2
      return 1
    end
  end
end