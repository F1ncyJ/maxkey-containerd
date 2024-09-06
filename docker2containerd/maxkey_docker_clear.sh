#!/bin/bash

nerdctl -n maxkey.top image ls -qa | xargs -r nerdctl -n maxkey.top image rm -f
echo "clear REPOSITORY IMAGE done."

nerdctl -n maxkey.top network ls -q | xargs -r nerdctl -n maxkey.top network rm
echo "clear NETWORK done."

nerdctl namespace remove maxkey.top
echo "clear NAMESPACE done."
