.PHONY: setup

setup: 
	if [ -f ${HOME}/.bash_dont_think.sh ]; then  \
		rm ${HOME}/.bash_dont_think.sh; \
	fi
	ln -s $(CURDIR)/.bash_dont_think.sh ${HOME}/.bash_dont_think.sh;

	if [ -f ${HOME}/.githelpers ]; then \
		rm ${HOME}/.githelpers; \
	fi
	ln -s $(CURDIR)/.githelpers ${HOME}/.githelpers;

	if [ -f ${HOME}/.profile ]; then \
		rm ${HOME}/.profile; \
	fi
	ln -s $(CURDIR)/.profile ${HOME}/.profile;

	if [ -f ${HOME}/.screenrc ]; then \
		rm  ${HOME}/.screenrc; \
	fi
	ln -s $(CURDIR)/.screenrc ${HOME}/.screenrc;

	if [ -f ${HOME}/.vim ]; then \
		rm  ${HOME}/.vim; \
	fi
	ln -s $(CURDIR)/.vim ${HOME}/.vim; 

	if [ -f ${HOME}/.vimrc ]; then \
		rm ${HOME}/.vimrc; \
	fi
	ln -s $(CURDIR)/.vimrc ${HOME}/.vimrc;

	if [ -f ${HOME}/android ]; then \
		rm ${HOME}/android; \
	fi
	ln -s $(CURDIR)/android ${HOME}/android;

	if [ -f ${HOME}/bin ]; then \
		rm ${HOME}/bin; \
	fi
	ln -s $(CURDIR)/bin ${HOME}/bin;


	if [ -f ${HOME}/.gitconfig ]; then \
		rm  ${HOME}/.gitconfig; \
	fi
	ln -s /Users/mlemley/Development/mlemley/DotFiles/.gitconfig ${HOME}/.gitconfig

	if [ -f ${HOME}/.githelpers ]; then \
		rm  ${HOME}/.githelpers; \
	fi
	$ ln -s /Users/mlemley/Development/mlemley/DotFiles/.githelpers ${HOME}/.githelpers

