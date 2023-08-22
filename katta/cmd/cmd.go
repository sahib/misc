package cmd

import (
	"fmt"
	"os"

	"github.com/sahib/misc/katta/db"
	"github.com/urfave/cli"
)

func withStore(fn func(ctx *cli.Context, store *db.Store) error) cli.ActionFunc {
	return func(ctx *cli.Context) error {
		dir := ctx.GlobalString("db")
		store, err := db.Open(dir, db.DefaultOptions())
		if err != nil {
			return err
		}

		defer store.Close()
		return fn(ctx, store)
	}
}

// Run runs the katta command line on `args` (args[0] should be os.Args[0])
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
		}, {
			Name:    "set",
			Aliases: []string{"s"},
			Usage:   "Set one or a several key-value pairs",
			Action:  withStore(handleSet),
		}, {
			Name:    "del",
			Aliases: []string{"d"},
			Usage:   "Delete one or several keys",
			Action:  withStore(handleDel),
		}, {
			Name:    "merge",
			Aliases: []string{"m"},
			Usage:   "Start the merge process manually",
			Action:  withStore(handleMerge),
		},
	}

	return app.Run(args)
}

func handleGet(ctx *cli.Context, store *db.Store) error {
	args := ctx.Args()
	for idx := 0; idx < len(args); idx++ {
		key := args[idx]
		data, err := store.Get(key)
		if err != nil && err != db.ErrKeyNotFound {
			return err
		}

		fmt.Printf("%s=%s\n", key, data)
	}

	return nil
}

func handleSet(ctx *cli.Context, store *db.Store) error {
	args := ctx.Args()
	if len(args)%2 != 0 {
		return fmt.Errorf("args have to be KEY1 VAL1 KEY2 VAL2 [...]")
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

func handleDel(ctx *cli.Context, store *db.Store) error {
	args := ctx.Args()
	for idx := 0; idx < len(args); idx++ {
		key := args[idx]
		if err := store.Del(key); err != nil {
			return err
		}
	}

	return nil
}

func handleMerge(ctx *cli.Context, store *db.Store) error {
	var round int
	for {
		merged, err := store.Merge()
		if err != nil {
			return err
		}

		if merged == 0 {
			return nil
		}

		round++
		fmt.Printf("merged %d segments in %d round", merged, round)
	}
}
