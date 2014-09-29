# French NLP under Vagrant

There are a lot of excellent tools online for tokenizing, tagging and
parsing French text.  These include:

- [Lefff][], a enormous database of French inflections distributed under
  the the [LGPL-LR][], a version of the LGPL modified for use with
  linguistic resources.
- [MElt][], a tokenizer, lemmatizer and part-of-speech tagger.
- [maltparser][], a natural language parser.
- [fremalt][], a pre-trained French for maltparser.  This is based on the
  [enhanced version][ftb+] of the [French Treebank][], which may be
  licensed for research use, or purchased for commercial use.

Unfortunately, getting this toolchain to work can take days of messing
around.  There are lots of dependencies, lots of out-of-date instructions
online, and lots of things that need to be patched up by hand.  Hence, this
repository provides a `Vagrantfile` to get everything running under
a [Vagrant][] VM.

[Lefff]: http://alpage.inria.fr/~sagot/lefff.html
[LGPL-LR]: http://www.ida.liu.se/~sarst/bitse/lgpllr.html
[MElt]: https://gforge.inria.fr/frs/?group_id=481&release_id=8412
[maltparser]: http://www.maltparser.org/
[fremalt]: http://www.maltparser.org/mco/french_parser/fremalt.html
[French Treebank]: http://www.llf.cnrs.fr/Gens/Abeille/French-Treebank-fr.php
[ftb+]: http://alpage.inria.fr/statgram/frdep/fr_stat_dep_parsing.html
[Vagrant]: https://www.vagrantup.com/

## Getting started with Vagrant

To create a new VM, log in, and parse a couple of sample paragraphs from
the [Gutenberg project][dumas], run:

```sh
vagrant up
# Get a cup of coffee.
vagrant ssh
cd /vagrant
cat sample.txt | tag | parse > sample.conllx
```

If this worked correctly, the file `sample.conllx` should contain output
like:

```
1       chapitre        chapitre        N       NC      _       0       root    _       _
2       premier premier A       ADJ     _       1       mod     _       _

1       les     le      D       DET     _       3       det     _       _
2       trois   *trois  A       ADJ     _       3       dep     _       _
3       présents        présent A       ADJ     _       0       root    _
       _
4       de      de      P       P       _       3       dep     _       _
5       m       *m      N       NC      _       4       obj     _       _
6       .       .       PONCT   PONCT   _       3       ponct   _       _
7       d'      de      P       P       _       3       dep     _       _
8       artagnan        *artagnan       D       DET     _       9       det     _       _
9       père    père    N       NC      _       7       obj     _       _
```

You can see that tools failed to understand the name _d'Artagnan_, possibly
because the original chapter title was fully capitalized.  It would
probably be possible to tune these tools and improve the results: In
general, the more the output of `tag` can be massaged to resemble the
[enhanced French Treebank][ftb+] training data, the better the results will
be.  This repository is just a starting point.

A few caveats:

- Make sure that your input text does not contain hard newlines in the
  middle of sentences.  This will confuse the cleanup steps.
- If you need to process text with lots of spelling errors, look at
  `extra/tag` and experiment with passing different options to `MElt`.

[dumas]: http://www.gutenberg.org/ebooks/13951

## Data formats

These tools use the [CoNLL-X data format][conllx], with French-specific
details from the [enhanced French Treebank][ftb+].  Details include:

- Sentences are separated by blank lines.
- Each non-blank line represents a word.
- The columns are, from left to right:
  1. `ID`: The position of the word within the sentence.
  2. `FORM`: The surface form of the word, after tokenization and basic
     cleanup.
  3. `LEMMA`: The underlying root form of the word.
  4. `CPOSTAG`: Coarse-grained part of speech ([details][postag]).
  5. `POSTAG`: Fine-grained part of speech ([details][postag]).
  6. `FEATS`: Features.  Currently unused by this toolchain, but it could
     probably be extracted from the Lefff lexicon with a bit of work.
  7. `HEAD`: The `ID` of this token's head, or 0 if this is a root.
  8. `DEPREL`: The relationship of this token to its head ([details][postag]).

The conversion from MElt's output format to the CoNLL-X format is handled
by script `extra/melt2conllx`, which is called automatically by our `tag`
wrapper.

[conllx]: http://ilk.uvt.nl/conll/#dataformat
[postag]: http://alpage.inria.fr/statgram/frdep/Publications/FTB-DescriptionDepSurface.pdf

## Other useful French NLP resources

These are some related resources which users of this VM might find
interesting:

- [Lexique][].  A nice, basic lexicon of French with frequency data.
  Distributed under a CC BY-NC-SA 3.0 non-commercial copyleft license.
- [Opus][].  A multilingual parallel corpus, including UN data and Open
  Subtitles.  A good chunk of the tagging is compatible with this
  toolchain.  Mostly open source.
- [French Wiktionary][].  A collaborative dictionary of French, with
  excellent coverage.  [Downloadable][frwikdown].
- [French Gutenberg books][Gutenberg].  Public domain ebooks.
  [Downloadable][gutdown].

If you happen to have some DRM-free ebooks available, you can use
[Calibre][] to covert them to text files:

```sh
sudo apt-get install calibre
ebook-convert mybook.epub mybook.txt
```

You might have some luck with buying the
[French version of _Harry Potter_][potterfr] from Pottermore, which will
give you about a million words of contemporary fiction.  Other than that,
the French DRM situation is pretty grim.

## Licensing

The code in the `packages` directory is distributed under a variety of
licenses, which you should inspect manually.  The new code added by this
project is placed into the public domain under the terms of the [Unlicense][].

[Lexique]: http://lexique.org/
[Opus]: http://opus.lingfil.uu.se/
[French Wiktionary]: http://fr.wiktionary.org/wiki/Wiktionnaire:Page_d%E2%80%99accueil
[frwikdown]: http://dumps.wikimedia.org/frwiktionary/
[Gutenberg]: http://www.gutenberg.org/wiki/Category:FR_Genre
[gutdown]: http://www.gutenberg.org/robot/harvest?filetypes[]=txt&langs[]=fr
[Calibre]: http://calibre-ebook.com/
[potterfr]: https://shop.pottermore.com/en_US/hpbundle1-7-ebook-french-fr1-eur
[Unlicense]: http://unlicense.org/
