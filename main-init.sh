#!/bin/bash

wdir=dirname $0
start_t= $(date %H%M%S)

echo "Starting server init at $start_t ..."
echo "   Packages & Softwares install"
$wdir/01-packages.sh

end_t= $(date %H%M%S)
echo "End of server init at $end_t ..."
