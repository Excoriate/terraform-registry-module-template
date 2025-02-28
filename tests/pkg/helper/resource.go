package helper

import (
	"fmt"
	"time"
)

// GenerateUniqueResourceName creates a unique resource name with a prefix and timestamp
func GenerateUniqueResourceName(prefix string) string {
	return fmt.Sprintf("%s-%s", prefix, time.Now().Format("20060102150405"))
}
