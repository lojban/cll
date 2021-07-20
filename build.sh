chcon -R -t container_file_t .
rm -rf build && ./run_container.sh -d && cp -avr build ~/public_html/cll
restorecon -FRv ~/public_html/cll
