package cmd

import (
	"fmt"
	"os"

	"github.com/sahib/misc/katta/kv"
	"github.com/urfave/cli"
)

func withStore(fn func(ctx *cli.Context, store *kv.Store) error) cli.ActionFunc {
	return func(ctx *cli.Context) error {
		dir := ctx.GlobalString("db")
		store, err := kv.Open(dir, kv.DefaultOptions())
		if err != nil {
			return err
		}

		defer store.Close()
		return fn(ctx, store)
	}
}

func Run(args []string) error {
	app := cli.NewApp()
	app.Name = "katta"
	app.Usage = "An educational key-value store"
	app.Version = "0.0.1"

	cwd, err := os.Getwd()
	if err != nil {
		return err
	}

	app.Flags = []cli.Flag{
		cli.StringFlag{
			Name:   "db",
			Usage:  "Path to database directory (defaults to curent working dir)",
			EnvVar: "KATTA_DB",
			Value:  cwd,
		},
	}

	app.Commands = []cli.Command{
		{
			Name:    "get",
			Aliases: []string{"g"},
			Usage:   "Get one or several keys",
			Action:  withStore(handleGet),
		},
		{
			Name:    "set",
			Aliases: []string{"s"},
			Usage:   "Set one or a several key-value pairs",
			Action:  withStore(handleSet),
		},
		{
			Name:    "del",
			Aliases: []string{"d"},
			Usage:   "Delete one or several keys",
			Action:  withStore(handleDel),
		},
	}

	return app.Run(args)
}

func handleGet(ctx *cli.Context, store *kv.Store) error {
	args := ctx.Args()
	for idx := 0; idx < len(args); idx++ {
		key := args[idx]
		data, err := store.Get(key)
		if err != nil && err != kv.ErrKeyNotFound {
			return err
		}

		fmt.Printf("%s=%s\n", key, data)
	}

	return nil
}

func handleSet(ctx *cli.Context, store *kv.Store) error {
	args := ctx.Args()
	if len(args)%2 == 0 {
		return fmt.Errorf("args have to be KEY1 VAL1 KEY2 VAL2...")
	}

	for idx := 0; idx < len(args); idx += 2 {
		key := args[idx+0]
		val := args[idx+1]
		if err := store.Set(key, []byte(val)); err != nil {
			return fmt.Errorf("set key=%s: %w", key, err)
		}
	}

	return nil
}

func handleDel(ctx *cli.Context, store *kv.Store) error {
	args := ctx.Args()
	for idx := 0; idx < len(args); idx++ {
		key := args[idx]
		if err := store.Del(key); err != nil {
			return err
		}
	}

	return nil
}
