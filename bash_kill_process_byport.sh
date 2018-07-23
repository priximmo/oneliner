lsof -i :80 | awk '{print $2}' | tail -n 1 | xargs kill
