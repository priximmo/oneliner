grep -Rl '/home/titi' * | xargs sed -i -e 's#/home/titi#/home/toto/appli1#g'
