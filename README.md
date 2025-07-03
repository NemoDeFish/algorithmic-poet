# 🌸 Algorithmic Poet — A Declarative Approach to Haiku Generation

**Algorithmic Poet** is a Haskell-based system that generates minimalist haikus using declarative programming techniques. It builds poems that conform to the classic **5-7-5** syllable structure, using a structured and systematic approach.

---

## ✍️ About Haikus

A **haiku** is a three-line poem with a syllabic structure of **5-7-5**. This project focuses solely on meeting that structural requirement. It does not attempt to enforce aesthetic qualities like seasonality or “cutting words.”

---

## 🔤 Word-to-Syllable Data

The project uses the `word_to_syllables.txt` file (based on the MRC Psycholinguistic Database) to determine the number of syllables in each word.

> ⚠️ Note: These functions are **not provided** in the repository. You must implement them yourself if you want to run the code:

* **`syllables :: String -> Maybe Int`**
  Returns the (minimum) number of syllables for a given word from the dataset.

* **`wordList :: [String]`**
  A list of all valid words present in the syllable data.



---

## 📘 Poem Representation

```haskell
type Poem = [String]
```

A haiku is represented as a list of 3 words (or 3 lines of words) that match the syllabic pattern.

---

## 🔧 Functions

### 1. `fillInPoem`

```haskell
fillInPoem :: [String] -> [Int] -> [Poem]
```

Generates all possible poems where each word in the poem exactly matches a required syllable count from the input list.

#### Example:

```haskell
fillInPoem ["flowering", "jacaranda", "photosynthesis"] [3,4,5]
-- Result: [["flowering", "jacaranda", "photosynthesis"]]

fillInPoem ["cabinet", "flowering", "jacaranda", "photosynthesis"] [3,4,5]
-- Result:
-- [["flowering", "jacaranda", "photosynthesis"],
--  ["cabinet", "jacaranda", "photosynthesis"]]
```

#### Important:

* Words must match syllable counts **exactly**
* Words in each poem must be **distinct**
* It will **not** combine multiple shorter words to meet a single syllable requirement

---

### 2. `generateAllHaikus`

```haskell
generateAllHaikus :: [String] -> [Poem]
```

Generates **all valid haikus** from the given word list that meet the **5-7-5** syllable structure, using only distinct words.

---

## 📂 Repository Structure

```
algorithmic-poet/
│
├── algorithmic_poet.hs        # Main Haskell source code for haiku generation
├── word_to_syllables.txt      # Word-to-syllables data (from the MRC Psycholinguistic Database)
└── README.md                  # Project documentation
```

---


## 🛠 Installation

### 1. Install GHC (Glasgow Haskell Compiler)

* **macOS**:

  ```bash
  brew install ghc
  ```
* **Ubuntu/Debian**:

  ```bash
  sudo apt install ghc
  ```
* Or download from: [https://www.haskell.org/ghc/](https://www.haskell.org/ghc/)

### 2. Clone This Repository

```bash
git clone https://github.com/NemoDeFish/algorithmic-poet
cd algorithmic-poet
```

---

## 🚀 Usage

### Load in GHCi

```bash
ghci algorithmic_poet.hs
```

### Run Example Queries

```haskell
-- Example: Generate haikus from a word list
generateAllHaikus ["red", "banksia", "flowering"]

-- Example: Match custom syllable pattern
fillInPoem ["flowering", "jacaranda", "photosynthesis"] [3,4,5]
```

---

## ⚠️ Limitations

* The program does **not** assess poetic meaning or aesthetics—only syllable count.
* Syllable data must be preprocessed or handled by user-defined `syllables` and `wordList` functions.
* Only the **minimum** syllable count is considered for words with multiple pronunciations.