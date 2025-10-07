#!/bin/bash
echo "=== Файлы с нарушениями DI ==="

echo ""
echo "1. FavoritesManager.shared usage:"
grep -r "FavoritesManager\.shared" --include="*.swift" . | grep -v "Tests" | cut -d: -f1 | sort -u

echo ""
echo "2. RatingManager.shared usage:"
grep -r "RatingManager\.shared" --include="*.swift" . | grep -v "Tests" | cut -d: -f1 | sort -u

echo ""
echo "3. TextSizeManager.shared usage:"
grep -r "TextSizeManager\.shared" --include="*.swift" . | grep -v "Tests" | cut -d: -f1 | sort -u

echo ""
echo "4. LocalizationManager.shared usage:"
grep -r "LocalizationManager\.shared" --include="*.swift" . | grep -v "Tests" | cut -d: -f1 | sort -u

echo ""
echo "5. ReadingProgressTracker.shared usage:"
grep -r "ReadingProgressTracker\.shared" --include="*.swift" . | grep -v "Tests" | cut -d: -f1 | sort -u

echo ""
echo "6. DefaultCategoriesRepository.shared usage:"
grep -r "DefaultCategoriesRepository\.shared" --include="*.swift" . | grep -v "Tests" | cut -d: -f1 | sort -u
