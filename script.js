const menuButton = document.querySelector(".menu-button");
const mobileMenu = document.querySelector(".mobile-menu");

menuButton?.addEventListener("click", () => {
  const isOpen = mobileMenu.classList.toggle("open");
  menuButton.setAttribute("aria-expanded", String(isOpen));
});

document.querySelectorAll(".mobile-menu a").forEach((link) => {
  link.addEventListener("click", () => {
    mobileMenu.classList.remove("open");
    menuButton.setAttribute("aria-expanded", "false");
  });
});

document.querySelector(".contact-form")?.addEventListener("submit", (event) => {
  event.preventDefault();
  const button = event.currentTarget.querySelector("button");
  button.innerHTML = "Inquiry ready <span>✓</span>";
  setTimeout(() => {
    button.innerHTML = 'Send inquiry <span>↗</span>';
  }, 3000);
});

document.querySelector("#year").textContent = new Date().getFullYear();

const caseStudyModal = document.querySelector("#pharmacy-case-study");

document.querySelector('[data-case-study="pharmacy"]')?.addEventListener("click", () => {
  if (typeof caseStudyModal.showModal === "function") {
    caseStudyModal.showModal();
  } else {
    caseStudyModal.setAttribute("open", "");
  }
});

document.querySelector(".modal-close")?.addEventListener("click", () => {
  caseStudyModal.close();
});

caseStudyModal?.addEventListener("click", (event) => {
  if (event.target === caseStudyModal) {
    caseStudyModal.close();
  }
});
