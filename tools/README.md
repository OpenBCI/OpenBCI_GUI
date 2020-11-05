# Simple script to convert output files from GUI 4.x to GUI 5.x

### Steps to convert the file:
1. Navigate to this tools folder in command prompt
2. Before converting the file, you require brainflow package.
3. For Linux based system:
```
sudo pip3 install -r requirements.txt
```

For windows based system:
```
pip install -r requirements.txt
```
4. After installing the required packages
5. Use the following command to convert the old file to new file.

```
python3 gui_old_to_new_file_converter.py --old %path_to_old_file% --new %file_to_create%
```
