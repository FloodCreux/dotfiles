package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"time"
)

func main() {
	second_brain := os.Getenv("SECOND_BRAIN") + "/0-inbox"
	filename := getFileName(os.Args)

	full_path := filepath.Join(second_brain, filename+".md")
	if _, err := os.Stat(full_path); err == nil {
		fmt.Println("File already exists.")
		return
	}

	err := createFile(full_path)
	if err != nil {
		return
	}

	openFileInEditor(full_path)
}

func getFileName(args []string) string {
	if len(args) < 2 {
		fmt.Print("Enter a filename: ")
		scanner := bufio.NewScanner(os.Stdin)
		scanner.Scan()
		return scanner.Text()
	} else if len(args) > 2 {
		fmt.Println("Please provide only one filename separated by dashes, without `.md` extension.")
		fmt.Println("Example: zet my-new-note")
		os.Exit(1)
	}
	return args[1]
}

func createFile(filepath string) error {
	file, err := os.Create(filepath)
	if err != nil {
		fmt.Println("Error creating the file:", err)
		return err
	}
	defer file.Close()

	timestamp := time.Now().Format("20060102150405")
	_, err = file.WriteString(fmt.Sprintf("# \n\n\nLinks:\n%s\n", timestamp))
	if err != nil {
		fmt.Println("Error writing to the file:", err)
		return err
	}

	fmt.Println("Note created at:", filepath)
	return err
}

func openFileInEditor(filepath string) error {
	cmd := exec.Command("nvim", filepath)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}
