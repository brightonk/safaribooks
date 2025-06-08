#!/bin/bash
set -euo pipefail

while getopts b: option
do
    case "${option}" in
        b)  BOOK_ID=${OPTARG};;
        *)  echo "Error: aborting"
        exit 1 ;;
    esac
done

CURDIR=$(pwd)
output_pdf="${CURDIR}/download/pdf"
output_epub="${CURDIR}/download/epub"

mkdir -p "$output_pdf"
mkdir -p "$output_epub"

python3 -m venv venv
source venv/bin/activate
python3 -m pip install -r requirements.txt

echo "Downloading both PDF and EPUB"
python3 safaribooks.py ${BOOK_ID}

echo "DEBUG: Getting book title from Books directory..."
LONG_TITLE=$(ls Books | head -1)
echo "DEBUG: LONG_TITLE = $LONG_TITLE"

# Replace unsafe characters with underscore or remove them entirely
# This will:
# - Replace slashes (/) with dashes
# - Remove or replace other potentially unsafe characters
# - Trim multiple underscores
# - Convert spaces to underscores

# Step-by-step cleanup
TITLE=$(echo "$LONG_TITLE" | \
  tr '/' '-' | \
  sed 's/[^A-Za-z0-9._-]/_/g' | \
  sed 's/_\+/_/g' | \
  sed 's/^_//' | \
  sed 's/_$//')

downloaded_epub_ebook_path="Books/${LONG_TITLE}/${BOOK_ID}.epub"
pdf_book_path="download/pdf/${BOOK_ID}_${TITLE}.pdf"
epub_book_path="download/epub/${BOOK_ID}_${TITLE}.epub"

echo "DEBUG: downloaded_epub_ebook_path = $downloaded_epub_ebook_path"
echo "DEBUG: pdf_book_path = $pdf_book_path"
echo "DEBUG: epub_book_path = $epub_book_path"

echo "DEBUG: print_pdf is true, converting EPUB to PDF..."
ebook-convert "${downloaded_epub_ebook_path}" "${pdf_book_path}"

mv "${downloaded_epub_ebook_path}" "${epub_book_path}"

rm -rf "Books/${LONG_TITLE}"
rm -rf "Books"

echo "$TITLE downloaded successfully"
