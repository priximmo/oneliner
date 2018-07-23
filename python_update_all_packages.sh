pip freeze --local | awk -F "=" '{print "pip install -U "$1}' | sh
