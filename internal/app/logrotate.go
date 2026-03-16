package app

import (
	"compress/gzip"
	"errors"
	"io"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"
)

const (
	DefaultMaxLogs     = 3
	DefaultMaxAgeDays  = 30
	CompressionEnabled = true
)

type LogRotateConfig struct {
	MaxLogs    int
	MaxAgeDays int
	Compress   bool
}

var DefaultConfig = LogRotateConfig{
	MaxLogs:    DefaultMaxLogs,
	MaxAgeDays: DefaultMaxAgeDays,
	Compress:   CompressionEnabled,
}

func RotateLogFile(logPath string) error {
	return RotateLogFileWithConfig(logPath, DefaultConfig)
}

func RotateLogFileWithConfig(logPath string, config LogRotateConfig) error {
	if config.MaxLogs < 1 {
		return errors.New("MaxLogs must be at least 1")
	}

	if err := cleanupOldLogs(logPath, config.MaxAgeDays); err != nil {
		return err
	}

	if err := compressOldLogs(logPath, config.MaxLogs, config.Compress); err != nil {
		return err
	}

	if err := shiftLogs(logPath, config.MaxLogs); err != nil {
		return err
	}

	return nil
}

func shiftLogs(logPath string, maxLogs int) error {
	if _, err := os.Stat(logPath); os.IsNotExist(err) {
		return nil
	}

	oldest := logPath + "." + strconv.Itoa(maxLogs)
	if err := os.Remove(oldest); err != nil && !os.IsNotExist(err) {
		return err
	}

	for i := maxLogs - 1; i >= 1; i-- {
		oldPath := logPath + "." + strconv.Itoa(i)
		newPath := logPath + "." + strconv.Itoa(i+1)

		if err := os.Rename(oldPath, newPath); err != nil && !os.IsNotExist(err) {
			return err
		}
	}

	if err := os.Rename(logPath, logPath+".1"); err != nil && !os.IsNotExist(err) {
		return err
	}

	return nil
}

func compressOldLogs(logPath string, maxLogs int, compress bool) error {
	if !compress {
		return nil
	}

	for i := 2; i <= maxLogs; i++ {
		logFile := logPath + "." + strconv.Itoa(i)
		gzFile := logFile + ".gz"

		if _, err := os.Stat(gzFile); err == nil {
			continue
		}

		if _, err := os.Stat(logFile); os.IsNotExist(err) {
			continue
		}

		if err := compressFile(logFile, gzFile); err != nil {
			continue
		}

		// Ignore removal error: .gz was created successfully; the source will be cleaned up
		// on the next rotation or by age-based cleanup.
		_ = os.Remove(logFile)
	}

	return nil
}

func compressFile(src, dst string) error {
	source, err := os.Open(src)
	if err != nil {
		return err
	}
	defer source.Close()

	destination, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer destination.Close()

	writer := gzip.NewWriter(destination)
	defer writer.Close()

	_, err = io.Copy(writer, source)
	return err
}

func cleanupOldLogs(logPath string, maxAgeDays int) error {
	if maxAgeDays <= 0 {
		return nil
	}

	dir := filepath.Dir(logPath)
	base := filepath.Base(logPath)

	entries, err := os.ReadDir(dir)
	if err != nil {
		return nil
	}

	cutoff := time.Now().AddDate(0, 0, -maxAgeDays)

	for _, entry := range entries {
		if entry.IsDir() {
			continue
		}

		name := entry.Name()
		if !strings.HasPrefix(name, base) {
			continue
		}

		info, err := entry.Info()
		if err != nil {
			continue
		}

		if info.ModTime().Before(cutoff) {
			// Ignore removal error: age-based cleanup is best-effort.
			_ = os.Remove(filepath.Join(dir, name))
		}
	}

	return nil
}
