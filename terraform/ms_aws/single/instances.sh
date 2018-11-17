#!/usr/bin/env bash

#if [[ $EUID -ne 0 ]]; then
#  echo -e "\nERROR: This script must be run as root\n" 1>&2
#  exit 1
#fi

BASENAME=$0

print_usage() {
  ERROR_MSG="$1"

  if [ "$ERROR_MSG" != "" ]; then
    echo "\nERROR: $ERROR_MSG\n" 1>&2
  fi

  echo ""
  echo "Usage:" 
  echo "       $BASENAME prod web/app/db/legacy/start/backend N"
  echo "       $BASENAME staging web/app/db/backend N"
  echo ""
  echo "  The first argument to the script must be an envirnoment name sucha as prod or staging"
  echo ""
  echo "  The Second argument to the scipt must be in which catagory instances have to be created, such as "
  echo "    web  -  This option is to create Proxy instances in provided envirnoment."
  echo "    app  -  This option is to create App instances."
  echo "    db   -  This option is to create DB instances in Internal zone."
  echo "    legacy - This option is used with prod envirnoment."
  echo "    backend - This option is to create backend servers like LDAP, file, index, Email etc. A single instance will serve for all."
  echo "    start - This option is to create JIRA/WIKI server."
  echo ""
  echo "  The Third argument to the script must be numeric - Number of instances to create."
  echo ""
} # end print_usage

# Vaildate number of parameters
if [ "$#" -gt 3 ]; then
  print_usage "Only 3 Parameters are allowed"
  exit 1
fi

# Validate 1st parameter
if [ -z "$1" ]; then
  print_usage "Must specify the envirnoment, such as prod or staging"
  exit 1
fi
INSTANCE_ENV=$1

# Validate 2nd parameter
if [ -z "$2" ]; then
  print_usage "Must specify the type of server, such as web/app/db/legacy/start/backend"
  exit 1
fi
SERVER_TYPE=$2

# Validate 3rd Argument
if [ -z "$3" ]; then
  print_usage "Must specify the Instance count"
  exit 1
fi
re='^[0-9]+$'
if ! [[ $3 =~ $re ]]; then
#if ! [ "$3" -eq "$3" ] 
  print_usage "Third paramter must be an integer."
  exit 1
fi
INSTANCE_COUNT=$3

if [[ $INSTANCE_COUNT == 0 ]]; then
	print_usage "Count should not be 0. It should be more than 0"
	exit 1
fi

# Availability zone
if [ $INSTANCE_ENV == "prod" ]; then
  AZ_ID="us-west-1a"
elif [ "$INSTANCE_ENV" == "staging" ]; then
  AZ_ID="us-west-1c"
else
  print_usage "Invalid Parameter $INSTANCE_ENV !"
  exit 1
fi

is_eip=0

case $SERVER_TYPE in
    web|WEB)
        if [ "$INSTANCE_ENV" == "prod" ]; then
       	    SUBNET_ID="subnet-89f247ee"
        elif [ "$INSTANCE_ENV" == "staging" ]; then
	    SUBNET_ID="subnet-e46c97bf"
        else
	    print_usage "Invalid Parameter $INSTANCE_ENV !"
    	    exit 1
        fi
	SG_NAME="nextgen_proxy_security_group"
	INSTANCE_TYPE="t2.small"
	is_eip=1
    ;;
    app|APP)
        if [ $INSTANCE_ENV == "prod" ]; then
    	    SUBNET_ID="subnet-f7f14490"
            SG_NAME="nextgen_prod_app_security_group"
        elif [ "$INSTANCE_ENV" == "staging" ]; then
    	    SUBNET_ID="subnet-9e619ac5"
	    SG_NAME="nextgen_staging_app_security_group"
        else
    	    print_usage "Invalid Parameter $INSTANCE_ENV !"
    	    exit 1
        fi
	INSTANCE_TYPE="c4.xlarge"
    ;;
    db|DB)
        if [ $INSTANCE_ENV == "prod" ]; then
            SUBNET_ID="subnet-f8f1449f"
	    SG_NAME="nextgen_prod_db_security_group"
        elif [ "$INSTANCE_ENV" == "staging" ]; then
            SUBNET_ID="subnet-a86398f3"
            SG_NAME="nextgen_staging_db_security_group"
        else
    	    print_usage "Invalid Parameter $INSTANCE_ENV !"
    	    exit 1
        fi
	INSTANCE_TYPE="m4.large"
    ;;
    legacy|LEGACY)
        if [ $INSTANCE_ENV == "prod" ]; then
            SUBNET_ID="subnet-62f04505"
	    SG_NAME="nextgen_prod_app_security_group"
        else
    	    print_usage "This option is available with prod parameter."
    	    exit 1
        fi
	INSTANCE_TYPE="t2.small"
    ;;
    start|START)
        if [ $INSTANCE_ENV == "prod" ]; then
            SUBNET_ID="subnet-f7f14490"
            SG_NAME="nextgen_prod_app_security_group"
        else
            print_usage "This option is available with prod parameter."
            exit 1
        fi
        INSTANCE_TYPE="c4.xlarge"
    ;;
    backend|BACKEND)
        if [ $INSTANCE_ENV == "prod" ]; then
            SUBNET_ID="subnet-f8f1449f"
            SG_NAME="nextgen_prod_support_security_group"
        elif [ "$INSTANCE_ENV" == "staging" ]; then
            SUBNET_ID="subnet-a86398f3"
            SG_NAME="nextgen_staging_support_security_group"
        else
            print_usage "Invalid Parameter $INSTANCE_ENV !"
            exit 1
        fi
	INSTANCE_TYPE="m4.large"
    ;;
    *)
        print_usage "Unrecognized or misplaced argument: $SERVER_TYPE !"
        exit 1
esac

# Export All variables in temp file.

echo > aws_vars.tfvars

cat > aws_vars.tfvars <<EOL
subnet_id = "$SUBNET_ID"
az_id = "$AZ_ID"
sg_name = "$SG_NAME"
instance_type = "$INSTANCE_TYPE"
is_eip = "$is_eip"
instance_count = "$INSTANCE_COUNT"
app_name = "$INSTANCE_ENV-$SERVER_TYPE-$(date +%m%d%y-%H%M%S)"
EOL

if [[ $(/Users/test/terraform/terraform state list | wc -l) -ne 0 ]]
then
   for item  in $(/Users/test/terraform/terraform state list)
   do
     /Users/test/terraform/terraform state rm $item 
   done
fi

# Run Terraform Script to create Instances.
/Users/test/terraform/terraform apply -var-file=aws_vars.tfvars ../single/

