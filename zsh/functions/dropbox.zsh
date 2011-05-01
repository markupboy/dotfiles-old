#############################
# various dropbox functions #
#############################

#fix dropbox permisions
fixdropbox () {
	echo 'fixing dropbox permissions'
	sudo chown -R $USER ~/Dropbox
	sudo chmod -R u+rw ~/Dropbox
	sudo chown -R $USER ~/.dropbox
	sudo chmod -R u+rw ~/.dropbox
}