# InvestingInMeAPI
Developed in Vapor

By: Jarrod, Liam & Johnny

## Documentation
- [Setting up Tests](CREATING_TESTS.md)
- [Creating Files and Folders](CREATING_FILES_FOLDERS.md)

## Useful Tips

- If there's a change in the `Package.swift`, always do a `vapor build`, followed by `vapor xcode -y`. This re-generates your xcode files as well as updates your libraries/dependicies.
- If you need to wipe out all your tables, then do `vapor run prepare --revert -all`. If this doesn't work, you can just wipe it out your database manually, through either Postico or terminal, or whatever database you choose.
- If you only need to wipe out the latest batch of preparations, then do `vapor run prepare --revert`. This is useful, when you want to revert a latest change you didn't need.
- If you want to see more information regarding on the commands you've ran, then you can append `--verbose` at the end, to get more information.


## Libraries Used
- Vapor Swift Framework
- PostgreSQL