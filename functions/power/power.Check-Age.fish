function power.Check-Age
  # Check if age is installed
  if not command -q age
    echo "Installing age..."
    if not sudo apt-get install -y age
      echo "Failed to install age!" >&2
      return 1
    end
  end
end