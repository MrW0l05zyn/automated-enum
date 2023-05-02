#!/bin/bash

# threads
threadsNmap='T5'    # T3 default
threadsDirsearch=25 # 25 default
threadsWfuzz=20     # 10 default

# timeout
reqDelayWfuzz=10    # 90 default
connDelayWfuzz=10   # 90 default

# proxy settings
enableProxy=false
ipProxy=127.0.0.1
portProxy=9090