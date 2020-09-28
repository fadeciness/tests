#!/bin/bash

process_pom_file() {
  result=""
lineNumber=$(grep -n "<artifactId>$1" $2 | grep -Eo '^[^:]+')
if [ -z "$lineNumber" ]
then
	#echo "No dependency"
	result=""
else
	lineNumber=$((lineNumber+1))
	versionTag=$(sed "${lineNumber}q;d" $2 | grep 'version')
	#echo "VersionTag and number:" $versionTag
	if [ -z "$versionTag" ]
	then
		#echo "Version is not specified"
		result="latest"
	else
		extractedVersion=$(echo $versionTag | sed 's/\(<version>\|<\/version>\)//g')
		#echo "Version without tags:" $extractedVersion
		if [[ $extractedVersion = \$* ]]
		then
			variableName=$(echo "$extractedVersion" | sed 's/\(${\|}\)//g')
			#echo "Detected variable. Variable name without brackets:" $variableName
			result=$(grep "<$variableName>" $2 | sed 's/.*>\(.*\)<.*/\1/')
		else
			result=$extractedVersion
		fi
	fi
fi
echo $result
}

process_gradle_file() {
  result=""
dependencyLine=$(grep -m 1 ":$1" $2)
#echo "Raw dependency line:" $dependencyLine
if [ -z "$dependencyLine" ]
then
	#echo "No dependency"
	result=""
else
	dependency=$(echo $dependencyLine | cut -d '"' -f 2)
	dependency=$(echo $dependency | cut -d "'" -f 2)
	#echo "Dependency line without quotes:" $dependency
	version=$(echo $dependency | sed "s/.*:$1\(.*\)/\1/")
	#echo "Version cut:" $version
	if [ -z "$version" ]
	then
		#echo "Version is not specified"
		result="latest"
	else
		extractedVersion=$(echo $version | cut -d ':' -f 2)
		if [[ $extractedVersion = \$* ]]
		then
			variableName=$(echo "$extractedVersion" | sed 's/\(${\|}\)//g')
			#echo "Detected variable. Variable name without brackets:" $variableName
			versionWithQuotes=$(grep "$variableName" $2 | grep '=' | sed -r "s/^[^=]+//")
			result=$(echo $versionWithQuotes | cut -d '"' -f 2)
			result=$(echo $result | cut -d "'" -f 2)
		else
			result=$extractedVersion
		fi
	fi
fi
echo $result
}

get_version() {
  version=""
  if [[ "$2" == *"pom.xml"*]]
  then
    version=$(process_pom_file $1 $2)
  else
    version=$(process_gradle_file $1 $2)
  fi
  echo $version
}

get_version $1 $2