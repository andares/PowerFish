function power.Check-Python
  # Check if Python is installed
  if not command -q python3
    echo "Installing python..."
    if not sudo apt-get install -y python3
      echo "Failed to install python!" >&2
      return 1
    end
  end

  # Check if pip is installed
  if not command -q pip3
    echo "Installing python-pip..."
    if not sudo apt-get install -y python3-pip
      echo "Failed to install pip!" >&2
      return 1
    end
  end
end