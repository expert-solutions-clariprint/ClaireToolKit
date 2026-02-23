# Dotenv

**Dotenv** read the .env file and create environment variables.


## Usage

### With command line

load .env in current working directory
```bash
claire -dotenv
```

load myfile as a .env file
```bash
claire -file-env myfile
```

You can use it multiple times

```bash
claire -file-env /etc/project.evn -file-env local.env  -dotenv
```


### by code

Dotenv/loadenv()


## License

Licensed under **Apache License 2.0**. See `LICENSE`.
