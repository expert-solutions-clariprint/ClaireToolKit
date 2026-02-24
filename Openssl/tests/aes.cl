

[alongtext(l:integer) : port
-> let out := port!()
in (while (l > 0) (putc(char!(40 + random(128 - 40)), out), l :- 1),
    out)]


(let x1 := port!(),
    a_secret := "mysecret",
    x := alongtext(4024),
    ref := string!(x)
in (//fwrite("a test string", x),
    set_index(x, 0),
    let out := port!()
    in (aes_encrypt(x,out,a_secret),
        set_index(out, 0),
        printf("Encrypted(~A): ~A\n", length(out), out),
        set_index(out, 0),
        let decrypted_port := port!(),
            decrypted := aes_decrypt(out,decrypted_port,a_secret),
            decrypted_str := string!(decrypted)
        in (set_index(decrypted, 0),
            if (decrypted_str = ref)
                printf("Decrypted successfully: ~S\n", length(decrypted_str))
            else
                printf("ERROR: ~S", string!(decrypted)),
            none),
        fclose(x))))

