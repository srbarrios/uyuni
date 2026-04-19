import { render, screen } from "utils/test-utils";

import { AllSystems } from "./all-list";

jest.mock("components/table/Table", () => ({
  Table: ({ titleButtons }) => <div>{titleButtons}</div>,
}));

describe("AllSystems", () => {
  test('renders "New system" action button', () => {
    render(<AllSystems docsLocale="en" isAdmin />);

    const newSystemLink = screen.getByRole("link", { name: "New system" });
    expect(newSystemLink.getAttribute("href")).toBe("/rhn/manager/systems/bootstrap");
    expect(screen.queryByRole("link", { name: "Add new system" })).toBeNull();
  });
});
