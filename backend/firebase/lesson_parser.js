const fs = require('fs');
const path = require('path');
const matter = require('gray-matter');
const marked = require('marked');

function parseFlashcards(content) {
  const flashcardRegex = /\[flashcards\]([\s\S]*?)\[\/flashcards\]/;
  const match = content.match(flashcardRegex);
  if (!match) return [];

  const flashcardsContent = match[1];
  const flashcardBlocks = flashcardsContent.split('\n- ').filter(block => block.trim());

  return flashcardBlocks.map(block => {
    const front = block.match(/front: (.*)/)?.[1] || '';
    const back = block.match(/back: (.*)/)?.[1] || '';
    const pronunciation = block.match(/pronunciation: (.*)/)?.[1] || '';
    const example = block.match(/example: (.*)/)?.[1] || '';

    return {
      korean: front.trim(),
      english: back.trim(),
      pronunciation: pronunciation.trim(),
      example: example.trim()
    };
  });
}

function parseQuiz(content) {
  const quizRegex = /\[quiz\]([\s\S]*?)\[\/quiz\]/;
  const match = content.match(quizRegex);
  if (!match) return { questions: [] };

  const quizContent = match[1];
  const questionBlocks = quizContent.split('\n- ').filter(block => block.trim());

  const questions = questionBlocks.map(block => {
    const question = block.match(/question: (.*)/)?.[1] || '';
    const options = [];
    const optionsMatch = block.match(/options:[\s\S]*?correct:/);
    if (optionsMatch) {
      const optionsContent = optionsMatch[0];
      options.push(...optionsContent.match(/- (.*)/g).map(opt => opt.slice(2).trim()));
    }
    const correctIndex = parseInt(block.match(/correct: (\d+)/)?.[1] || '0');

    return {
      question: question.trim(),
      options,
      correctIndex
    };
  });

  return { questions };
}

function parseLessonFile(filePath) {
  const fileContent = fs.readFileSync(filePath, 'utf8');
  const { data, content } = matter(fileContent);
  
  // Convert markdown content to HTML (excluding flashcards and quiz sections)
  const contentWithoutSections = content
    .replace(/\[flashcards\][\s\S]*?\[\/flashcards\]/, '')
    .replace(/\[quiz\][\s\S]*?\[\/quiz\]/, '');
  
  const htmlContent = marked.parse(contentWithoutSections);

  return {
    id: data.id,
    title: data.title,
    description: data.description,
    level: data.level,
    category: data.category,
    order: data.order,
    content: htmlContent,
    flashcards: parseFlashcards(content),
    quiz: parseQuiz(content)
  };
}

function processLessons() {
  const lessonsDir = path.join(__dirname, '../content/lessons');
  const lessons = [];

  fs.readdirSync(lessonsDir)
    .filter(file => file.endsWith('.md'))
    .forEach(file => {
      const lessonPath = path.join(lessonsDir, file);
      const lesson = parseLessonFile(lessonPath);
      lessons.push(lesson);
    });

  // Sort lessons by order
  lessons.sort((a, b) => a.order - b.order);

  // Write to JSON file
  const outputPath = path.join(__dirname, '../assets/processed_lessons.json');
  fs.writeFileSync(outputPath, JSON.stringify({ lessons }, null, 2));
  console.log(`Processed ${lessons.length} lessons and saved to ${outputPath}`);
  
  return lessons;
}

module.exports = {
  processLessons
};