# DI Violations Report
$(date)

## Files with direct manager dependencies:

### FavoritesManager.shared
$(grep -r "FavoritesManager\.shared" --include="*.swift" . | grep -v "Tests" | cut -d: -f1 | sort -u | sed 's/^/- /')

### RatingManager.shared
$(grep -r "RatingManager\.shared" --include="*.swift" . | grep -v "Tests" | cut -d: -f1 | sort -u | sed 's/^/- /')

### TextSizeManager.shared
$(grep -r "TextSizeManager\.shared" --include="*.swift" . | grep -v "Tests" | cut -d: -f1 | sort -u | sed 's/^/- /')

### LocalizationManager.shared
$(grep -r "LocalizationManager\.shared" --include="*.swift" . | grep -v "Tests" | cut -d: -f1 | sort -u | sed 's/^/- /')
