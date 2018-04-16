########################################################################
#
# Manage ML Hub Models
#
########################################################################

define MLHUB_HELP
Makefile for Managing ML Models

Local targets:

  mlhub		Update https://mlhub.ai/.

endef
export MLHUB_HELP

help::
	@echo "$$MLHUB_HELP"

########################################################################
# REPOSITORY
########################################################################

REPO_HOST = mlhub.ai
BASE_PATH = /var/www/html
REPO_PATH = pool/main
REPO_USER = root
REPO_URL  = https://$(REPO_HOST)$(BASE_PATH)$(REPO_PATH)
REPO_SSH  = $(REPO_USER)@$(REPO_HOST)

########################################################################
# MODEL ARCHIVE
########################################################################

DESCRIPTION = DESCRIPTION.yaml

MODEL = $(shell basename `pwd`)
INIT_CHAR = $(shell printf %.1s "$(MODEL)")
MODEL_PATH = $(REPO_PATH)/$(INIT_CHAR)/$(MODEL)
MODEL_MLM = $(MODEL)_$(MODEL_VERSION).mlm
MODEL_VERSION = $(shell grep version $(DESCRIPTION) | awk '{print $$NF}')
MODEL_FILENAME = \ \ filename     : $(REPO_PATH)/$(INIT_CHAR)/$(MODEL)/$(MODEL_MLM)
MODEL_DATE =     \ \ date         : $(shell date +"%F %T")

test:
	@echo $(MODEL)
	@echo $(MODEL_PATH)
	@echo $(MODEL_VERSION)
	@echo $(MODEL_FILENAME)
	@echo $(MODEL_DATE)


# Don't create YAML file, just a temporary file???


local:
	rsync -avzh $(MODEL_FILES) ~/.aipk/$(MODEL)/

cleanlocal:
	rm -rf ~/.aipk/$(MODEL)/

mlhub: $(MODEL_MLM)
	ssh $(REPO_SSH) mkdir -p $(BASE_PATH)/$(MODEL_PATH)
	rsync -avzh $^ $(REPO_SSH):$(BASE_PATH)/$(MODEL_PATH)/
	ssh $(REPO_SSH) chmod -R a+rX $(BASE_PATH)/$(REPO_PATH)

$(MODEL_MLM): $(MODEL_FILES)
	perl -pi -e 's|  filename.*$$|$(MODEL_FILENAME)|' $(DESCRIPTION)
	perl -pi -e 's|  date.*$$|$(MODEL_DATE)|' $(DESCRIPTION)
	(cd ..; zip -r $(MODEL)/$@ $(addprefix $(MODEL)/,$(MODEL_FILES)))

$(MODEL_YAML): $(MODEL_YML)
	sed -e "s|meta:|meta:\\n$(MODEL_FILENAME)|g" $^ |\
	tr -d "'" > $@
	echo "" >> $@
