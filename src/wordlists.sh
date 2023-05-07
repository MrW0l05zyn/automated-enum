#!/bin/bash

# paths
secListsDirectory='/usr/share/seclists'

# directories
wordlistSmallDirectories=$secListsDirectory/Discovery/Web-Content/raft-small-directories.txt
wordlistMediumDirectories=$secListsDirectory/Discovery/Web-Content/raft-medium-directories.txt
wordlistLargeDirectories=$secListsDirectory/Discovery/Web-Content/raft-large-directories.txt
wordlistDirectories=$wordlistMediumDirectories

# files
wordlistSmallFiles=$secListsDirectory/Discovery/Web-Content/raft-small-files.txt
wordlistMediumFiles=$secListsDirectory/Discovery/Web-Content/raft-medium-files.txt
wordlistLargeFiles=$secListsDirectory/Discovery/Web-Content/raft-large-files.txt
wordlistFiles=$wordlistMediumDirectories

# words
wordlistSmallWords=$secListsDirectory/Discovery/Web-Content/raft-small-words.txt
wordlistMediumWords=$secListsDirectory/Discovery/Web-Content/raft-medium-words.txt
wordlistLargeWords=$secListsDirectory/Discovery/Web-Content/raft-large-words.txt
wordlistWords=$wordlistSmallWords

# extensions
wordlistExtensions='php' # php-config-jsp-aspx-sh-html-txt-bak-old