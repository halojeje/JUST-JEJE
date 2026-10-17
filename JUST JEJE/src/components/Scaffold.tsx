import React from "react";

export interface ScaffoldProps {
  appBar?: React.ReactNode;
  children: React.ReactNode;
  floatingActionButton?: React.ReactNode;
  className?: string;
  bodyClassName?: string;
}

/**
 * Standardized Scaffold layout component used by Dashboard, Generator, and Settings.
 * Ensures identical sizing, padding, and layout structure across all pages.
 */
export const Scaffold: React.FC<ScaffoldProps> = ({
  appBar,
  children,
  floatingActionButton,
  className = "",
  bodyClassName = "",
}) => {
  return (
    <div className={`page-scaffold ${className}`}>
      {appBar && <header className="scaffold-appbar">{appBar}</header>}
      <main className={`scaffold-body ${bodyClassName}`}>{children}</main>
      {floatingActionButton && (
        <div className="scaffold-fab">{floatingActionButton}</div>
      )}
    </div>
  );
};
