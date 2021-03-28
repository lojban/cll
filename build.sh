rm -rf build && ./run_container.sh -d -T xhtml_nochunks && cp -avr build ~/public_html/cll && restorecon -FRv ~/public_html/cll
