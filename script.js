// yeah this is my todo app

var STORAGE = 'mytodos';
var tasks = [];
let currentView = 'all';

const form = document.getElementById('todo-form');
const input = document.getElementById('todo-input');
const list = document.getElementById('list');
const counter = document.getElementById('counter');

function load() {
  let saved = localStorage.getItem(STORAGE);
  if (saved) {
    try {
      tasks = JSON.parse(saved);
    } catch(e) {
      tasks = [];
    }
  }
  let view = localStorage.getItem('todo_view');
  if (view) currentView = view;
}

function save() {
  localStorage.setItem(STORAGE, JSON.stringify(tasks));
  localStorage.setItem('todo_view', currentView);
}

function filtered() {
  if (currentView === 'active') {
    return tasks.filter(t => !t.done);
  }
  if (currentView === 'done') {
    return tasks.filter(t => t.done);
  }
  return tasks;
}

function render() {
  let items = filtered();
  list.innerHTML = '';
  items.forEach(task => {
    let li = document.createElement('li');
    li.className = task.done ? 'done' : '';
    li.innerHTML =
      '<span class="cb" data-id="' + task.id + '">&#' + (task.done ? '10003' : '9673') + ';</span> ' +
      '<span class="txt">' + task.title + '</span> ' +
      '<span class="del" data-id="' + task.id + '">&#10005;</span>';
    list.appendChild(li);
  });
  let left = tasks.filter(t => !t.done).length;
  counter.textContent = left + ' left';
}

// highlight current filter
function highlightView(v) {
  document.querySelectorAll('.filter-btn').forEach(b => {
    if (b.dataset.view === v) {
      b.classList.add('active');
    } else {
      b.classList.remove('active');
    }
  });
}

form.addEventListener('submit', function(e) {
  e.preventDefault();
  let val = input.value.trim();
  if (!val) return;

  // quick duplicate check
  for (let i = 0; i < tasks.length; i++) {
    if (tasks[i].title.toLowerCase() === val.toLowerCase()) {
      alert('already got that one');
      input.value = '';
      return;
    }
  }

  tasks.push({ id: Date.now(), title: val, done: false });
  save();
  render();
  input.value = '';
  input.focus();
});

list.addEventListener('click', function(e) {
  let target = e.target;

  // toggle done
  if (target.classList.contains('cb')) {
    let id = parseInt(target.dataset.id);
    for (let i = 0; i < tasks.length; i++) {
      if (tasks[i].id === id) {
        tasks[i].done = !tasks[i].done;
        break;
      }
    }
    save();
    render();
    return;
  }

  // delete
  if (target.classList.contains('del')) {
    let id = parseInt(target.dataset.id);
    tasks = tasks.filter(t => t.id !== id);
    save();
    render();
  }
});

document.querySelector('.filters').addEventListener('click', function(e) {
  let btn = e.target.closest('.filter-btn');
  if (!btn) return;
  currentView = btn.dataset.view;
  save();
  highlightView(currentView);
  render();
});

// eh, might need this later
console.log('todo app loaded');

load();
highlightView(currentView);
render();
