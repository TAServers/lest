local success = os.execute([[npm install -g luabundler luamin]])
os.exit(success and 0 or 1)
